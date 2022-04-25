# Declare this file as a StarkNet contract.
%lang starknet

from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin, BitwiseBuiltin
from starkware.cairo.common.math import assert_nn, assert_le, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.alloc import alloc

from starkware.cairo.common.bool import TRUE, FALSE

from contracts.models.common import Vector2, Dust, Cell
from contracts.interfaces.iship import IShip
from contracts.interfaces.irand import IRandom
from contracts.core.library import MathUtils_clamp_value, MathUtils_random_in_range, MathUtils_random_direction
from contracts.libraries.grid import (
    grid, grid_size, next_grid, _get_grid_size, _get_ship_at, _get_dust_at, _get_next_turn_dust_at,
    _get_next_turn_ship_at, _set_dust_at, _set_ship_at, _set_next_turn_dust_at,
    _set_next_turn_ship_at, _get_grid_state, _clear_next_turn_dust_at, _clear_dust_at)

# ------------
# STORAGE VARS
# ------------

@storage_var
func _initialized() -> (res : felt):
end

@storage_var
func max_turn_count() -> (count : felt):
end

@storage_var
func current_turn() -> (num : felt):
end

@storage_var
func current_dust_count() -> (count : felt):
end

@storage_var
func max_dust_count() -> (count : felt):
end

@storage_var
func ship_counter() -> (id : felt):
end

@storage_var
func ship(id : felt) -> (contract_address : felt):
end

@storage_var
func dust_generation_seed() -> (seed : felt):
end

@storage_var
func rand_contract() -> (rand_contract : felt):
end

@storage_var
func scores(ship_id : felt) -> (score : felt):
end

# -----
# VIEWS
# -----

@view
func get_max_turn_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        count : felt):
    let (count) = max_turn_count.read()
    return (count)
end

@view
func get_max_dust_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        count : felt):
    let (count) = max_dust_count.read()
    return (count)
end

@view
func get_current_turn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        num : felt):
    let (num) = current_turn.read()
    return (num)
end

@view
func get_grid_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        grid_state_len : felt, grid_state : Cell*):
    return _get_grid_state()
end

@view
func get_grid_size{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        size : felt):
    return _get_grid_size()
end

@view
func get_score{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(ship_id : felt) -> (
        score : felt):
    let (score) = scores.read(ship_id)
    return (score=score)
end

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
func dust_moved(
        space_contract_address : felt, previous_position : Vector2,
        position : Vector2):
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
func new_turn(space_contract_address : felt, turn_number: felt):
end

@event
func game_finished(space_contract_address : felt):
end

# -----------
# CONSTRUCTOR
# -----------

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    return ()
end

@external
func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        rand_contract_address : felt, size : felt, turn_count : felt, max_dust : felt):
    _only_not_initialized()
    rand_contract.write(rand_contract_address)
    grid_size.write(size)
    max_turn_count.write(turn_count)
    max_dust_count.write(max_dust)
    return ()
end

# ------------------
# EXTERNAL FUNCTIONS
# ------------------

@external
func play_game{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():

    _rec_play_turns()

    return ()
end

func _rec_play_turns{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():
    let (is_finished) = next_turn()
    if is_finished == TRUE:
        let (space_contract_address) = get_contract_address()
        game_finished.emit(space_contract_address)

        return ()
    end

    _rec_play_turns()
    return ()
end

# This function must be invoked to process the next turn of the game.
@external
func next_turn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*}() -> (is_finished: felt):
    alloc_locals

    let (turn) = current_turn.read()
    let (max_turn) = max_turn_count.read()

    let (local still_palying) = is_le(turn + 1, max_turn)
    if still_palying == 0:
        return (TRUE)
    end

    current_turn.write(turn + 1)

    let (space_contract_address) = get_contract_address()
    new_turn.emit(space_contract_address, turn + 1)

    _spawn_dust()

    _move_dust(0, 0)
    let (grid_state_len, grid_state) = get_grid_state()
    with grid_state_len, grid_state:
        _move_ships(0, 0)
    end
    _update_grid(0, 0)

    return (FALSE)
end

@external
func add_ship{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt, ship_contract : felt):
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

    # Register the ship contract under a new id
    let (last_ship_id) = ship_counter.read()
    let new_id = last_ship_id + 1
    ship.write(new_id, ship_contract)

    # Put the ship on grids
    _set_next_turn_ship_at(x, y, new_id)
    _set_ship_at(x, y, new_id)

    # Emit events
    let (space_contract_address) = get_contract_address()
    ship_added.emit(space_contract_address, new_id, Vector2(x, y))

    return ()
end

# ------------------
# INTERNAL FUNCTIONS
# ------------------

func _only_not_initialized{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (initialized) = _initialized.read()
    with_attr error_message("Initializable: contract already initialized"):
        assert initialized = FALSE
    end
    _initialized.write(TRUE)
    return ()
end

func _spawn_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():
    alloc_locals
    let (local size) = _get_grid_size()
    let (local dust_count) = current_dust_count.read()
    let (max_dust) = max_dust_count.read()

    # Check if we already reached the max amount of dust in the grid
    if dust_count == max_dust:
        return ()
    end

    # Create a new Dust at random position on a border and with random direction
    let (local dust : Dust, position : Vector2) = _generate_random_dust_on_border()

    # Check there is no dust at this position yet
    let other_dust : Dust = _get_next_turn_dust_at(position.x, position.y)
    if other_dust.present == TRUE:
        # There is already some dust here, so let's just skip dust spawning this turn
        return ()
    end

    # Finally, add dust to the grid
    _set_next_turn_dust_at(position.x, position.y, dust)
    current_dust_count.write(dust_count + 1)

    let (contract_address) = get_contract_address()
    dust_spawned.emit(contract_address, dust.direction, position)

    return ()
end

# Recursive function that goes through the entire grid and updates dusts position
func _move_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt):
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
    else:
        # No collision. Update the dust position in the grid
        _set_next_turn_dust_at(new_position.x, new_position.y, dust)

        let (space_contract_address) = get_contract_address()
        dust_moved.emit(space_contract_address, Vector2(x, y), new_position)

        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    # process the next cell
    _move_dust(x, y + 1)
    return ()
end

func _update_grid{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt):
    let (size) = _get_grid_size()

    # We reached the last cell, this is the end
    if x == size:
        return ()
    end
    # We reached the end of the column, let's go to the next one
    if y == size:
        _update_grid(x + 1, 0)
        return ()
    end

    let (cell : Cell) = next_grid.read(Vector2(x, y))
    grid.write(Vector2(x, y), cell)

    # process the next cell
    _update_grid(x, y + 1)
    return ()
end

# Recursive function that goes through the entire grid and updates ships position
func _move_ships{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_state_len,
        grid_state : Cell*}(x : felt, y : felt):
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
    let (ship_contract) = ship.read(ship_id)
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
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    # Update the dust position in the grid
    _set_next_turn_ship_at(x, y, 0)
    _set_next_turn_ship_at(new_x, new_y, ship_id)

    # process the next cell
    _move_ships(x, y + 1)
    return ()
end

func _handle_collision_with_other_ship{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        old_x : felt, old_y : felt, new_x : felt, new_y : felt) -> (x : felt, y : felt):
    let (other_ship : felt) = _get_next_turn_ship_at(new_x, new_y)
    if other_ship != 0:
        return (old_x, old_y)
    end
    return (new_x, new_y)
end

func _catch_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        dust : Dust, position : Vector2, ship_id : felt):
    assert dust.present = TRUE

    let (dust_count) = current_dust_count.read()
    assert_nn(dust_count)
    current_dust_count.write(dust_count - 1)

    let (current_score) = scores.read(ship_id)
    scores.write(ship_id, current_score + 1)

    # Emit event so the front can remove it from the grid
    let (contract_address) = get_contract_address()
    dust_destroyed.emit(contract_address, position)

    return ()
end

func _burn_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        dust : Dust, position : Vector2):
    assert dust.present = TRUE

    let (dust_count) = current_dust_count.read()
    assert_nn(dust_count)
    current_dust_count.write(dust_count - 1)

    let (contract_address) = get_contract_address()
    dust_destroyed.emit(contract_address, position)

    return ()
end

# Generate random dust given a space size
func _generate_random_dust_on_border{
        pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*}() -> (dust : Dust, position : Vector2):
    alloc_locals
    local dust : Dust
    assert dust.present = TRUE

    let (seed) = dust_generation_seed.read()
    dust_generation_seed.write(seed + 1)

    let (rand_contract_address) = rand_contract.read()
    let (r1, r2, r3, r4, r5) = IRandom.generate_random_numbers(
        rand_contract_address, seed)

    let (direction : Vector2) = MathUtils_random_direction(r1, r2)
    assert dust.direction = direction

    let (position : Vector2) = _generate_random_position_on_border(r3, r4, r5)

    return (dust=dust, position=position)
end

# Generate a random position on a given border (top, left, right, bottom)
func _generate_random_position_on_border{
        pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(r1, r2, r3) -> (position : Vector2):
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
func _shuffled_position{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
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


func _compute_new_dust_position{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(dust : Dust, current_position : Vector2) -> (
        new_position : Vector2):
    alloc_locals

    let (new_hdir) = _get_new_hdir(dust, current_position)
    let (new_vdir) = _get_new_vdir(dust, current_position)

    let new_x = current_position.x + new_hdir
    let new_y = current_position.y + new_vdir

    return (new_position=Vector2(x=new_x, y=new_y))
end

func _get_new_hdir{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
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

func _get_new_vdir{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
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