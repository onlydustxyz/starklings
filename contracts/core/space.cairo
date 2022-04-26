# Declare this file as a StarkNet contract.
%lang starknet

from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin, BitwiseBuiltin
from starkware.cairo.common.math import assert_nn, assert_le, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.alloc import alloc

from starkware.cairo.common.bool import TRUE, FALSE

from contracts.models.common import Vector2, Dust, Cell, Context, ShipInit
from contracts.interfaces.iship import IShip
from contracts.interfaces.irand import IRandom
from contracts.core.library import (
    MathUtils_clamp_value, MathUtils_random_in_range, MathUtils_random_direction)
from contracts.libraries.grid import (
    _get_grid_size, _get_ship_at, _get_dust_at, _get_next_turn_dust_at, _get_next_turn_ship_at,
    _set_dust_at, _set_ship_at, _set_next_turn_dust_at, _set_next_turn_ship_at, _get_grid_state,
    _clear_next_turn_dust_at, _clear_dust_at, _get_next_cell_at, _get_cell_at, _set_cell_at,
    _set_next_cell_at, _init_grid, _increment_ship_score, _sync_two_grids)

# ------
# EVENTS
# ------

@event
func dust_spawned(space_contract_address : felt, direction : Vector2, position : Vector2):
end

@event
func dust_destroyed(space_contract_address : felt, position : Vector2):
end

@event
func dust_moved(space_contract_address : felt, previous_position : Vector2, position : Vector2):
end

@event
func ship_added(space_contract_address : felt, ship_id : felt, position : Vector2):
end

@event
func ship_moved(
        space_contract_address : felt, ship_id : felt, previous_position : Vector2,
        position : Vector2):
end

@event
func score_changed(space_contract_address : felt, ship_id : felt, score : felt):
end

@event
func new_turn(space_contract_address : felt, turn_number : felt):
end

@event
func game_finished(space_contract_address : felt):
end

# ------------------
# EXTERNAL FUNCTIONS
# ------------------

@external
func play_game{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr}(
        rand_contract_address : felt, size : felt, turn_count : felt, max_dust : felt,
        ships_len : felt, ships : ShipInit*):
    alloc_locals

    local context : Context

    let grid : Cell* = alloc()
    let next_grid : Cell* = alloc()
    let ships_addresses : felt* = alloc()
    assert context.grid_size = size
    assert context.grid = grid
    assert context.next_grid = next_grid
    assert context.max_turn_count = turn_count
    assert context.max_dust = max_dust
    assert context.rand_contract = rand_contract_address
    assert context.ships_len = ships_len
    assert context.ships = ships_addresses

    _init_grid(size * size, context.grid)
    _init_grid(size * size, context.next_grid)

    let dust_count = 0
    let scores : felt* = alloc()

    with context, dust_count, scores:
        _add_ships(ships_len, ships)
        _rec_play_turns(0)
    end

    return ()
end

# ------------------
# INTERNAL FUNCTIONS
# ------------------
func _add_ships{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*, context : Context}(ships_len : felt, ships : ShipInit*):
    if ships_len == 0:
        return ()
    end

    _add_ship(
        [ships].position.x, [ships].position.y, [ships].address, context.ships_len - ships_len + 1)
    return _add_ships(ships_len - 1, ships + ShipInit.SIZE)
end

func _rec_play_turns{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*, context : Context, dust_count : felt, scores : felt*}(
        current_turn : felt):
    let (is_finished) = _next_turn(current_turn)
    if is_finished == TRUE:
        let (space_contract_address) = get_contract_address()
        game_finished.emit(space_contract_address)

        return ()
    end

    _rec_play_turns(current_turn + 1)
    return ()
end

# This function must be invoked to process the next turn of the game.
func _next_turn{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*, context : Context, dust_count : felt, scores : felt*}(
        current_turn : felt) -> (is_finished : felt):
    alloc_locals

    let max_turn = context.max_turn_count

    let (local still_palying) = is_le(current_turn + 1, max_turn)
    if still_palying == 0:
        return (TRUE)
    end

    let (space_contract_address) = get_contract_address()
    new_turn.emit(space_contract_address, current_turn + 1)

    with current_turn:
        _spawn_dust()
    end

    _move_dust(0, 0)
    let (grid_state_len, grid_state) = _get_grid_state()
    with grid_state_len, grid_state:
        _move_ships(0, 0)
    end
    _sync_two_grids()

    return (FALSE)
end

func _add_ship{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt, ship_contract : felt, ship_id : felt):
    alloc_locals

    # Check other ship
    let (ship_at_position : felt) = _get_ship_at(x, y)
    with_attr error_message("Space: cell is not free"):
        assert ship_at_position = 0
    end

    # Check dust
    let dust : Dust = _get_dust_at(x, y)
    with_attr error_message("Space: cell is not free"):
        assert dust.present = FALSE
    end

    # Put the ship on grids
    _set_next_turn_ship_at(x, y, ship_id)
    _set_ship_at(x, y, ship_id)
    assert [context.ships + ship_id - 1] = ship_contract

    # Emit events
    let (space_contract_address) = get_contract_address()
    ship_added.emit(space_contract_address, ship_id, Vector2(x, y))

    return ()
end

func _spawn_dust{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*, context : Context, dust_count : felt, current_turn : felt}():
    alloc_locals
    let (local size) = _get_grid_size()
    let max_dust = context.max_dust

    # Check if we already reached the max amount of dust in the grid
    if dust_count == max_dust:
        return ()
    end

    # Create a new Dust at random position on a border and with random direction
    let (local dust : Dust, position : Vector2) = _generate_random_dust_on_border()
    # %{ print('Spawning dust at ({}) ({})'.format(ids.position.x, ids.position.y)) %}

    # Check there is no dust at this position yet
    let other_dust : Dust = _get_next_turn_dust_at(position.x, position.y)
    # %{ print("Other dust present: {}".format(ids.other_dust)) %}
    if other_dust.present == TRUE:
        # There is already some dust here, so let's just skip dust spawning this turn
        return ()
    end

    # Finally, add dust to the grid

    _set_next_turn_dust_at(position.x, position.y, dust)
    # %{ print("after set next turn dust") %}

    let (contract_address) = get_contract_address()
    dust_spawned.emit(contract_address, dust.direction, position)

    return ()
end

# Recursive function that goes through the entire grid and updates dusts position
func _move_dust{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context,
        dust_count : felt, scores : felt*}(x : felt, y : felt):
    alloc_locals
    let (size) = _get_grid_size()

    # We reached the last cell, this is the end
    if x == size:
        return ()
    end
    # We reached the end of the column, let's go to the next one
    if y == size:
        _move_dust(x + 1, 0)
        return ()
    end

    let (local dust : Dust) = _get_dust_at(x, y)

    # if there is no dust here, we go directly to the next cell
    if dust.present == FALSE:
        _move_dust(x, y + 1)
        return ()
    end

    # There is some dust here! Let's move it
    let (local new_position : Vector2) = _compute_new_dust_position(dust, Vector2(x, y))

    # As the dust position changed, we free its old position
    _clear_next_turn_dust_at(x, y)

    # Check collision with ship
    let (ship_id : felt) = _get_ship_at(new_position.x, new_position.y)
    if ship_id != 0:
        # transfer dust to the ship and process next cell
        _catch_dust(dust, Vector2(new_position.x, new_position.y), ship_id)
        _move_dust(x, y + 1)
        return ()
    end

    # Check collision
    let (local other_dust : Dust) = _get_next_turn_dust_at(new_position.x, new_position.y)

    if other_dust.present == TRUE:
        # In case of collision, do not assign the dust to the cell. The dust is lost forever.
        _burn_dust(dust, Vector2(x, y))

        # see https://www.cairo-lang.org/docs/how_cairo_works/builtins.html#revoked-implicit-arguments
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
        tempvar context = context
        tempvar dust_count = dust_count
    else:
        # No collision. Update the dust position in the grid
        _set_next_turn_dust_at(new_position.x, new_position.y, dust)

        let (space_contract_address) = get_contract_address()
        dust_moved.emit(space_contract_address, Vector2(x, y), new_position)

        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
        tempvar context = context
        tempvar dust_count = dust_count
    end

    # process the next cell
    _move_dust(x, y + 1)
    return ()
end

# Recursive function that goes through the entire grid and updates ships position
func _move_ships{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_state_len,
        grid_state : Cell*, context : Context, dust_count : felt, scores : felt*}(
        x : felt, y : felt):
    alloc_locals
    let (size) = _get_grid_size()

    # We reached the last cell, this is the end
    if x == size:
        return ()
    end
    # We reached the end of the column, let's go to the next one
    if y == size:
        _move_ships(x + 1, 0)
        return ()
    end

    let (local ship_id : felt) = _get_ship_at(x, y)

    # if there is no ship here, we go directly to the next cell
    if ship_id == 0:
        _move_ships(x, y + 1)
        return ()
    end

    # Call ship contract
    let ship_contract = [context.ships + ship_id - 1]
    let (local new_direction : Vector2) = IShip.move(
        ship_contract, grid_state_len, grid_state, ship_id)
    let (direction_x) = MathUtils_clamp_value(new_direction.x, -1, 1)
    let (direction_y) = MathUtils_clamp_value(new_direction.y, -1, 1)

    # Compute new position and check borders
    let (candidate_x) = MathUtils_clamp_value(x + direction_x, 0, size - 1)
    let (candidate_y) = MathUtils_clamp_value(y + direction_y, 0, size - 1)

    # Check collision with other ship
    let (local new_x, new_y) = _handle_collision_with_other_ship(x, y, candidate_x, candidate_y)

    let (space_contract_address) = get_contract_address()
    # TODO: When ship have unique ID, use this instead of `0`
    ship_moved.emit(space_contract_address, 0, Vector2(x, y), Vector2(new_x, new_y))

    # Check collision with dust
    let (dust : Dust) = _get_dust_at(new_x, new_y)
    if dust.present == TRUE:
        # transfer dust to the ship
        _catch_dust(dust, Vector2(new_x, new_y), ship_id)

        # remove dust from the grid
        _clear_dust_at(new_x, new_y)
        _clear_next_turn_dust_at(new_x, new_y)

        # see https://www.cairo-lang.org/docs/how_cairo_works/builtins.html#revoked-implicit-arguments
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
        tempvar context = context
        tempvar dust_count = dust_count
        tempvar scores = scores
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
        tempvar context = context
        tempvar dust_count = dust_count
        tempvar scores = scores
    end

    # Update the dust position in the grid
    tempvar dust_count = dust_count
    tempvar scores = scores
    _set_next_turn_ship_at(x, y, 0)
    _set_next_turn_ship_at(new_x, new_y, ship_id)

    # process the next cell
    _move_ships(x, y + 1)
    return ()
end

func _handle_collision_with_other_ship{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        old_x : felt, old_y : felt, new_x : felt, new_y : felt) -> (x : felt, y : felt):
    let (other_ship : felt) = _get_next_turn_ship_at(new_x, new_y)
    if other_ship != 0:
        return (old_x, old_y)
    end
    return (new_x, new_y)
end

func _catch_dust{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context,
        dust_count : felt, scores : felt*}(dust : Dust, position : Vector2, ship_id : felt):
    alloc_locals
    _burn_dust(dust, position)
    local dust_count = dust_count
    _increment_ship_score(ship_id)

    return ()
end

func _burn_dust{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context,
        dust_count : felt}(dust : Dust, position : Vector2):
    assert dust.present = TRUE

    assert_nn(dust_count)
    let dust_count = dust_count - 1

    let (contract_address) = get_contract_address()
    dust_destroyed.emit(contract_address, position)

    return ()
end

# Generate random dust given a space size
func _generate_random_dust_on_border{
        pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*, context : Context, current_turn : felt}() -> (
        dust : Dust, position : Vector2):
    alloc_locals
    local dust : Dust
    assert dust.present = TRUE

    let (r1, r2, r3, r4, r5) = IRandom.generate_random_numbers(context.rand_contract, current_turn)

    let (direction : Vector2) = MathUtils_random_direction(r1, r2)
    assert dust.direction = direction

    let (position : Vector2) = _generate_random_position_on_border(r3, r4, r5)

    return (dust=dust, position=position)
end

# Generate a random position on a given border (top, left, right, bottom)
func _generate_random_position_on_border{
        pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, context : Context}(
        r1, r2, r3) -> (position : Vector2):
    alloc_locals
    let (space_size) = _get_grid_size()

    # x is 0 or space_size - 1
    let (x) = MathUtils_random_in_range(r1, 0, 1)
    local x = x * (space_size - 1)

    # y is in [0, space_size-1]
    let (y) = MathUtils_random_in_range(r2, 0, space_size - 1)

    return _shuffled_position(x, y, r3)
end

# given x, y return randomly Position(x,y) or Position(y,x)
func _shuffled_position{
        pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, context : Context}(
        x : felt, y : felt, r) -> (position : Vector2):
    alloc_locals
    local position : Vector2

    let (on_horizontal_border) = MathUtils_random_in_range(r, 0, 1)
    if on_horizontal_border == 0:
        assert position.x = x
        assert position.y = y
    else:
        assert position.x = y
        assert position.y = x
    end

    return (position=position)
end

func _compute_new_dust_position{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        dust : Dust, current_position : Vector2) -> (new_position : Vector2):
    alloc_locals

    let (new_hdir) = _get_new_hdir(dust, current_position)
    let (new_vdir) = _get_new_vdir(dust, current_position)

    let new_x = current_position.x + new_hdir
    let new_y = current_position.y + new_vdir

    return (new_position=Vector2(x=new_x, y=new_y))
end

func _get_new_hdir{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        dust : Dust, current_position : Vector2) -> (hdir : felt):
    alloc_locals
    let (space_size) = _get_grid_size()

    if current_position.x == space_size - 1:
        if dust.direction.x == 1:
            return (hdir=-1)
        end
    end

    if current_position.x == 0:
        if dust.direction.x == -1:
            return (hdir=1)
        end
    end

    return (hdir=dust.direction.x)
end

func _get_new_vdir{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        dust : Dust, current_position : Vector2) -> (vdir : felt):
    alloc_locals
    let (space_size) = _get_grid_size()

    if current_position.y == space_size - 1:
        if dust.direction.y == 1:
            return (vdir=-1)
        end
    end

    if current_position.y == 0:
        if dust.direction.y == -1:
            return (vdir=1)
        end
    end

    return (vdir=dust.direction.y)
end
