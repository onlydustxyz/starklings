# Declare this file as a StarkNet contract.
%lang starknet

from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import (
    Uint256, uint256_check, uint256_add, uint256_sub, uint256_mul, uint256_unsigned_div_rem,
    uint256_le, uint256_lt, uint256_eq)
from starkware.cairo.common.math import assert_nn, assert_le, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.alloc import alloc

from starkware.cairo.common.bool import TRUE, FALSE

from contracts.models.common import Vector2, Dust, Cell
from contracts.interfaces.idust import IDustContract
from contracts.interfaces.iship import IShip
from contracts.core.library import MathUtils_clamp_value

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
func grid_size() -> (size : felt):
end

@storage_var
func grid(position : Vector2) -> (cell : Cell):
end

@storage_var
func next_grid(position : Vector2) -> (cell : Cell):
end

@storage_var
func dust_contract() -> (contract : felt):
end

@storage_var
func current_dust_count() -> (count : felt):
end

@storage_var
func max_dust_count() -> (count : felt):
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
func get_current_turn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        num : felt):
    let (num) = current_turn.read()
    return (num)
end

@view
func get_grid_size{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        size : felt):
    let (size) = grid_size.read()
    return (size)
end

@view
func get_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt) -> (dust_id : Uint256):
    let (cell : Cell) = grid.read(Vector2(x, y))
    return (dust_id=cell.dust_id)
end

@view
func get_ship_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt) -> (ship : felt):
    let (cell : Cell) = grid.read(Vector2(x, y))
    return (ship=cell.ship)
end

@view
func get_grid_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        grid_state_len : felt, grid_state : Cell*):
    alloc_locals

    let (local grid_state : Cell*) = alloc()

    let (grid_state_len) = _rec_fill_grid_state(0, grid_state)

    return (grid_state_len, grid_state)
end

# ------
# EVENTS
# ------

@event
func dust_spawned(space_contract_address: felt, dust_id: Uint256, position: Vector2):
end

@event
func dust_destroyed(space_contract_address: felt, dust_id: Uint256, position: Vector2):
end

@event
func dust_moved(space_contract_address: felt, dust_id: Uint256, previous_position: Vector2, position: Vector2):
end

@event
func ship_added(space_contract_address: felt, ship_id: felt, position: Vector2):
end

@event
func ship_moved(space_contract_address: felt, ship_id: felt, previous_position: Vector2, position: Vector2):
end

@event
func score_changed(space_contract_address: felt, ship_id: felt, score: felt):
end

@event
func match_finished(space_contract_address: felt, winner_ship_id: felt):
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
        dust_contract_address : felt, size : felt, turn_count : felt, max_dust : felt):
    _only_not_initialized()
    dust_contract.write(dust_contract_address)
    grid_size.write(size)
    max_turn_count.write(turn_count)
    max_dust_count.write(max_dust)
    return ()
end

# ------------------
# EXTERNAL FUNCTIONS
# ------------------

# This function must be invoked to process the next turn of the game.
@external
func next_turn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (turn) = current_turn.read()
    let (max_turn) = max_turn_count.read()
    assert_le(turn + 1, max_turn)
    current_turn.write(turn + 1)

    _spawn_dust()

    _move_dust(0, 0)
    _move_ships(0, 0)
    _update_grid(0, 0)

    return ()
end

@external
func add_ship{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt, ship_contract : felt):
    alloc_locals

    # Check other ship
    let (ship_at_position : felt) = get_ship_at(x, y)
    with_attr error_message("Space: cell is not free"):
        assert ship_at_position = 0
    end

    # Check dust
    let dust_id : Uint256 = get_dust_at(x, y)
    let (no_dust_found) = uint256_eq(dust_id, Uint256(0, 0))
    with_attr error_message("Space: cell is not free"):
        assert no_dust_found = TRUE
    end

    _set_next_turn_ship_at(x, y, ship_contract)
    _set_ship_at(x, y, ship_contract)
    
    let (space_contract_address) = get_contract_address()
    # TODO: When each ship have it's unique identifier inside space, use this instead of `0`
    ship_added.emit(space_contract_address, 0, Vector2(x, y))
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

func _spawn_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (local size) = grid_size.read()
    let (local dust_count) = current_dust_count.read()
    let (max_dust) = max_dust_count.read()

    # Check if we already reached the max amount of dust in the grid
    if dust_count == max_dust:
        return ()
    end

    let (dust_contract_address) = dust_contract.read()

    # Create a new Dust at random position and with random direction
    let (token_id : Uint256) = IDustContract.mint_random_on_border(dust_contract_address, size)

    # Get created Dust metadata to retrieve its position
    let (local dust : Dust) = IDustContract.metadata(dust_contract_address, token_id)

    # Check there is no dust at this position yet
    let other_dust_id : Uint256 = _get_next_turn_dust_at(dust.position.x, dust.position.y)
    let (no_dust_found) = uint256_eq(other_dust_id, Uint256(0, 0))
    if no_dust_found == FALSE:
        IDustContract.burn(dust_contract_address, token_id)
        return ()
    end

    # Finally, add dust to the grid
    _set_next_turn_dust_at(dust.position.x, dust.position.y, token_id)
    current_dust_count.write(dust_count + 1)
    
    let (contract_address) = get_contract_address()
    dust_spawned.emit(contract_address, token_id, dust.position)

    return ()
end

# Returns internal id of dust - as stored in the grid - from its token id.
func _to_internal_dust_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        token_id : Uint256) -> (internal_dust_id : Uint256):
    let (internal_dust_id : Uint256, _) = uint256_add(token_id, Uint256(1, 0))
    return (internal_dust_id)
end

# Recursive function that goes through the entire grid and updates dusts position
func _move_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt):
    alloc_locals
    let (size) = grid_size.read()

    # We reached the last cell, this is the end
    if x == size:
        return ()
    end
    # We reached the end of the column, let's go to the next one
    if y == size:
        _move_dust(x + 1, 0)
        return ()
    end

    let (local dust_id : Uint256) = get_dust_at(x, y)

    # if there is no dust here, we go directly to the next cell
    let (no_dust_found) = uint256_eq(dust_id, Uint256(0, 0))
    if no_dust_found == TRUE:
        _move_dust(x, y + 1)
        return ()
    end

    # There is some dust here! Let's move it
    let (local dust_contract_address) = dust_contract.read()
    let (local moved_dust : Dust) = IDustContract.move(dust_contract_address, dust_id)

    # As the dust position changed, we free its old position
    _set_next_turn_dust_at(x, y, Uint256(0, 0))

    # Check collision with ship
    let (ship : felt) = get_ship_at(moved_dust.position.x, moved_dust.position.y)
    if ship != 0:
        # transfer dust to the ship and process next cell
        _catch_dust(dust_id, ship)
        _move_dust(x, y + 1)
        return ()
    end

    # Check collision
    let (local other_dust_id : Uint256) = _get_next_turn_dust_at(
        moved_dust.position.x, moved_dust.position.y)
    let (local no_other_dust) = uint256_eq(other_dust_id, Uint256(0, 0))

    if no_other_dust == FALSE:
        # In case of collision, burn the current dust
        _burn_dust(dust_id)

        # see https://www.cairo-lang.org/docs/how_cairo_works/builtins.html#revoked-implicit-arguments
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        # No collision. Update the dust position in the grid
        _set_next_turn_dust_at(moved_dust.position.x, moved_dust.position.y, dust_id)

        let (space_contract_address) = get_contract_address()
        dust_moved.emit(space_contract_address, dust_id, Vector2(x, y), moved_dust.position)

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
    let (size) = grid_size.read()

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
func _move_ships{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt):
    alloc_locals
    let (size) = grid_size.read()

    # We reached the last cell, this is the end
    if x == size:
        return ()
    end
    # We reached the end of the column, let's go to the next one
    if y == size:
        _move_ships(x + 1, 0)
        return ()
    end

    let (local ship : felt) = get_ship_at(x, y)

    # if there is no ship here, we go directly to the next cell
    if ship == 0:
        _move_ships(x, y + 1)
        return ()
    end

    let (grid_state_len, grid_state) = get_grid_state()

    # Call ship contract
    let (local new_direction : Vector2) = IShip.move(ship, grid_state_len, grid_state)
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
    let dust_id : Uint256 = get_dust_at(new_x, new_y)
    let (no_dust_found) = uint256_eq(dust_id, Uint256(0, 0))
    if no_dust_found == FALSE:
        # transfer dust to the ship
        _catch_dust(dust_id, ship)

        # remove dust from the grid
        _set_dust_at(new_x, new_y, Uint256(0, 0))
        _set_next_turn_dust_at(new_x, new_y, Uint256(0, 0))

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
    _set_next_turn_ship_at(new_x, new_y, ship)

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
        dust_id : Uint256, ship : felt):
    let (dust_count) = current_dust_count.read()
    assert_nn(dust_count)
    current_dust_count.write(dust_count - 1)

    let (space_contract_address) = get_contract_address()
    let (dust_contract_address) = dust_contract.read()

    IDustContract.safeTransferFrom(dust_contract_address, space_contract_address, ship, dust_id)
    
    # Emit event so the front can remove it from the grid
    let (dust) = IDustContract.metadata(dust_contract_address, dust_id)
    dust_destroyed.emit(space_contract_address, dust_id, dust.position)
    
    return ()
end

func _burn_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(dust_id: Uint256):
    let (space_contract_address) = get_contract_address()
    let (dust_contract_address) = dust_contract.read()
    
    let (dust) = IDustContract.metadata(dust_contract_address, dust_id)
    IDustContract.burn(dust_contract_address, dust_id)
    let (dust_count) = current_dust_count.read()
    assert_nn(dust_count)
    current_dust_count.write(dust_count - 1)
    
    dust_destroyed.emit(space_contract_address, dust_id, dust.position)
    
    return ()
end

func _rec_fill_grid_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        grid_state_len : felt, grid_state : Cell*) -> (len : felt):
    let (size) = grid_size.read()
    if size * size == grid_state_len:
        return (grid_state_len)
    end

    let (y, x) = unsigned_div_rem(grid_state_len, size)
    let (cell : Cell) = grid.read(Vector2(x=x, y=y))

    assert grid_state[grid_state_len] = Cell(cell.dust_id, cell.ship)
    return _rec_fill_grid_state(grid_state_len + 1, grid_state)
end

func _get_next_turn_ship_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt) -> (ship : felt):
    let (cell : Cell) = next_grid.read(Vector2(x, y))
    return (ship=cell.ship)
end

func _get_next_turn_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt) -> (dust_id : Uint256):
    let (cell : Cell) = next_grid.read(Vector2(x, y))
    return (dust_id=cell.dust_id)
end

func _set_ship_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt, ship : felt):
    let position = Vector2(x, y)
    grid.write(position, Cell(Uint256(0, 0), ship))
    return ()
end

func _set_next_turn_ship_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt, ship : felt):
    let position = Vector2(x, y)
    next_grid.write(position, Cell(Uint256(0, 0), ship))
    return ()
end

func _set_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt, dust_id : Uint256):
    let position = Vector2(x, y)
    grid.write(position, Cell(dust_id, 0))
    return ()
end

func _set_next_turn_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt, dust_id : Uint256):
    let position = Vector2(x, y)
    next_grid.write(position, Cell(dust_id, 0))
    return ()
end
