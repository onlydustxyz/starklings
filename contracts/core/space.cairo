# Declare this file as a StarkNet contract.
%lang starknet

from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_check,
    uint256_add,
    uint256_sub,
    uint256_mul,
    uint256_unsigned_div_rem,
    uint256_le,
    uint256_lt,
    uint256_eq,
)
from starkware.cairo.common.math import assert_nn, assert_le
from starkware.cairo.common.math_cmp import is_le

from starkware.cairo.common.bool import TRUE, FALSE

from contracts.models.common import Vector2, Dust
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
func dust_grid(x : felt, y : felt) -> (dust_id : Uint256):
end

@storage_var
func next_turn_dust_grid(x : felt, y : felt) -> (dust_id : Uint256):
end

@storage_var
func ship_grid(x : felt, y : felt) -> (ship : felt):
end

@storage_var
func next_turn_ship_grid(x : felt, y : felt) -> (ship : felt):
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
    count : felt
):
    let (count) = max_turn_count.read()
    return (count)
end

@view
func get_current_turn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    num : felt
):
    let (num) = current_turn.read()
    return (num)
end

@view
func get_grid_size{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    size : felt
):
    let (size) = grid_size.read()
    return (size)
end

@view
func get_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
) -> (dust_id : Uint256):
    let (dust_id : Uint256) = dust_grid.read(x, y)
    return (dust_id)
end

@view
func get_ship_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
) -> (ship : felt):
    let (ship : felt) = ship_grid.read(x, y)
    return (ship)
end

struct Cell:
    member position : Vector2
    member dust_id : Uint256
    member ship : felt
end

@view
func get_first_non_empty_cell{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
) -> (cell : Cell):
    alloc_locals
    assert_nn(x)
    assert_nn(y)
    let (size) = grid_size.read()

    let (x_limit_reached) = is_le(size, x)  # x >= size
    if x_limit_reached == TRUE:
        # We reached the last cell, this is the end
        return (Cell(Vector2(x, y), Uint256(0, 0), 0))
    end
    let (y_limit_reached) = is_le(size, y)  # y >= size
    if y_limit_reached == TRUE:
        # We reached the end of the column, let's go to the next one
        let (res : Cell) = get_first_non_empty_cell(x + 1, 0)
        return (res)
    end

    # If there is a ship, return it
    let (ship_at_position : felt) = ship_grid.read(x, y)
    if ship_at_position != 0:
        return (Cell(Vector2(x, y), Uint256(0, 0), ship_at_position))
    end

    # If there is some dust, return it
    let (local dust_id : Uint256) = dust_grid.read(x, y)
    let (no_dust_found) = uint256_eq(dust_id, Uint256(0, 0))
    if no_dust_found == FALSE:
        return (Cell(Vector2(x, y), dust_id, 0))
    end

    # Process the next cell
    let (res : Cell) = get_first_non_empty_cell(x, y + 1)
    return (res)
end

@view
func get_first_empty_cell{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
) -> (position : Vector2):
    alloc_locals
    assert_nn(x)
    assert_nn(y)
    let (size) = grid_size.read()

    # We reached the last cell, this is the end
    let (x_limit_reached) = is_le(size, x)  # x >= size
    if x_limit_reached == TRUE:
        return (Vector2(-1, -1))
    end
    # We reached the end of the column, let's go to the next one
    let (y_limit_reached) = is_le(size, y)  # y >= size
    if y_limit_reached == TRUE:
        let (res : Vector2) = get_first_empty_cell(x + 1, 0)
        return (res)
    end

    # If there is a ship, go to next cell
    let (ship_at_position : felt) = ship_grid.read(x, y)
    if ship_at_position != 0:
        let (res : Vector2) = get_first_empty_cell(x, y + 1)
        return (res)
    end

    # If there is some dust, go to next cell
    let (local dust_id : Uint256) = dust_grid.read(x, y)
    let (no_dust_found) = uint256_eq(dust_id, Uint256(0, 0))
    if no_dust_found == FALSE:
        let (res : Vector2) = get_first_empty_cell(x, y + 1)
        return (res)
    end

    # There is nothing here, return the current cell position
    return (Vector2(x, y))
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
    dust_contract_address : felt, size : felt, turn_count : felt, max_dust : felt
):
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
    _update_dust_grid(0, 0)

    _move_ships(0, 0)
    _update_ship_grid(0, 0)

    return ()
end

@external
func add_ship{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt, ship_contract : felt
) -> (position : Vector2):
    let (position : Vector2) = get_first_empty_cell(x, y)

    # Check that we actually found a free cell
    assert_nn(position.x)
    assert_nn(position.y)

    next_turn_ship_grid.write(position.x, position.y, ship_contract)
    ship_grid.write(position.x, position.y, ship_contract)
    return (position=position)
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
    let (other_dust_id) = next_turn_dust_grid.read(dust.position.x, dust.position.y)
    let (no_dust_found) = uint256_eq(other_dust_id, Uint256(0, 0))
    if no_dust_found == FALSE:
        IDustContract.burn(dust_contract_address, token_id)
        return ()
    end

    # Finally, add dust to the grid
    let (internal_dust_id : Uint256) = _to_internal_dust_id(token_id)
    next_turn_dust_grid.write(dust.position.x, dust.position.y, internal_dust_id)
    current_dust_count.write(dust_count + 1)
    return ()
end

# Returns internal id of dust - as stored in the grid - from its token id.
func _to_internal_dust_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (internal_dust_id : Uint256):
    let (internal_dust_id : Uint256, _) = uint256_add(token_id, Uint256(1, 0))
    return (internal_dust_id)
end

# Returns token id of dust from its internal id.
func _to_external_dust_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    internal_dust_id : Uint256
) -> (token_id : Uint256):
    let (token_id : Uint256) = uint256_sub(internal_dust_id, Uint256(1, 0))
    return (token_id)
end

# Recursive function that goes through the entire grid and updates dusts position
func _move_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
):
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

    let (local dust_id : Uint256) = dust_grid.read(x, y)

    # if there is no dust here, we go directly to the next cell
    let (no_dust_found) = uint256_eq(dust_id, Uint256(0, 0))
    if no_dust_found == TRUE:
        _move_dust(x, y + 1)
        return ()
    end

    # Compute token_id in NFT contract
    let (token_id : Uint256) = _to_external_dust_id(dust_id)

    # There is some dust here! Let's move it
    let (local dust_contract_address) = dust_contract.read()
    let (local moved_dust : Dust) = IDustContract.move(dust_contract_address, token_id)

    # As the dust position changed, we free its old position
    next_turn_dust_grid.write(x, y, Uint256(0, 0))

    # Check collision with ship
    let (ship : felt) = ship_grid.read(moved_dust.position.x, moved_dust.position.y)
    if ship != 0:
        # transfer dust to the ship and process next cell
        _ship_catches_dust(dust_id, ship)
        _move_dust(x, y + 1)
        return ()
    end

    # Check collision
    let (local other_dust_id : Uint256) = next_turn_dust_grid.read(
        moved_dust.position.x, moved_dust.position.y
    )
    let (local no_other_dust) = uint256_eq(other_dust_id, Uint256(0, 0))

    if no_other_dust == FALSE:
        # In case of collision, burn the current dust
        IDustContract.burn(dust_contract_address, token_id)
        let (dust_count) = current_dust_count.read()
        assert_nn(dust_count)
        current_dust_count.write(dust_count - 1)

        # see https://www.cairo-lang.org/docs/how_cairo_works/builtins.html#revoked-implicit-arguments
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        # No collision. Update the dust position in the grid
        next_turn_dust_grid.write(moved_dust.position.x, moved_dust.position.y, dust_id)
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    # process the next cell
    _move_dust(x, y + 1)
    return ()
end

func _update_dust_grid{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
):
    let (size) = grid_size.read()

    # We reached the last cell, this is the end
    if x == size:
        return ()
    end
    # We reached the end of the column, let's go to the next one
    if y == size:
        _update_dust_grid(x + 1, 0)
        return ()
    end

    let (dust_id : Uint256) = next_turn_dust_grid.read(x, y)
    dust_grid.write(x, y, dust_id)

    # process the next cell
    _update_dust_grid(x, y + 1)
    return ()
end

# Recursive function that goes through the entire grid and updates ships position
func _move_ships{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
):
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

    let (local ship : felt) = ship_grid.read(x, y)

    # if there is no ship here, we go directly to the next cell
    if ship == 0:
        _move_ships(x, y + 1)
        return ()
    end

    # Call ship contract
    let (local new_direction : Vector2) = IShip.move(ship)
    let (dx) = MathUtils_clamp_value(new_direction.x, -1, 1)
    let (dy) = MathUtils_clamp_value(new_direction.y, -1, 1)

    # Compute new position and check borders
    let (tmp_x) = MathUtils_clamp_value(x + dx, 0, size - 1)
    let (tmp_y) = MathUtils_clamp_value(y + dy, 0, size - 1)

    # Check collision with other ship
    let (local nx, ny) = _handle_collision_with_other_ship(x, y, tmp_x, tmp_y)

    # Check collision with dust
    let (dust_id : Uint256) = dust_grid.read(nx, ny)
    let (no_dust_found) = uint256_eq(dust_id, Uint256(0, 0))
    if no_dust_found == FALSE:
        # transfer dust to the ship
        _ship_catches_dust(dust_id, ship)

        # remove dust from the grid
        dust_grid.write(nx, ny, Uint256(0, 0))
        next_turn_dust_grid.write(nx, ny, Uint256(0, 0))

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
    next_turn_ship_grid.write(x, y, 0)
    next_turn_ship_grid.write(nx, ny, ship)

    # process the next cell
    _move_ships(x, y + 1)
    return ()
end

func _handle_collision_with_other_ship{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(old_x : felt, old_y : felt, new_x : felt, new_y : felt) -> (x : felt, y : felt):
    let (other_ship : felt) = next_turn_ship_grid.read(new_x, new_y)
    if other_ship != 0:
        return (old_x, old_y)
    end
    return (new_x, new_y)
end

func _update_ship_grid{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
):
    let (size) = grid_size.read()

    # We reached the last cell, this is the end
    if x == size:
        return ()
    end
    # We reached the end of the column, let's go to the next one
    if y == size:
        _update_ship_grid(x + 1, 0)
        return ()
    end

    let (ship : felt) = next_turn_ship_grid.read(x, y)
    ship_grid.write(x, y, ship)

    # process the next cell
    _update_ship_grid(x, y + 1)
    return ()
end

func _ship_catches_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    dust_id : Uint256, ship : felt
):
    let (dust_count) = current_dust_count.read()
    assert_nn(dust_count)
    current_dust_count.write(dust_count - 1)

    let (contract_address) = get_contract_address()
    let (dust_contract_address) = dust_contract.read()

    let (token_id : Uint256) = _to_external_dust_id(dust_id)
    IDustContract.safeTransferFrom(dust_contract_address, contract_address, ship, token_id)
    return ()
end
