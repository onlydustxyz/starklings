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
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.math_cmp import is_le

from starkware.cairo.common.bool import TRUE, FALSE
from openzeppelin.access.ownable import Ownable_initializer, Ownable_only_owner

from contracts.models.dust import Vector2, Dust
from contracts.interfaces.dust import IDustContract
from contracts.interfaces.ship import IShip

# ------------
# STORAGE VARS
# ------------

@storage_var
func _initialized() -> (res : felt):
end

@storage_var
func grid_size() -> (size : felt):
end

@storage_var
func grid_dust(x : felt, y : felt) -> (dust_id : Uint256):
end

@storage_var
func next_turn_grid_dust(x : felt, y : felt) -> (dust_id : Uint256):
end

@storage_var
func grid_ship(x : felt, y : felt) -> (ship : felt):
end

@storage_var
func next_turn_grid_ship(x : felt, y : felt) -> (ship : felt):
end

@storage_var
func dust_contract() -> (contract : felt):
end

# -----
# VIEWS
# -----

@view
func get_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
) -> (dust_id : Uint256):
    let (dust_id : Uint256) = grid_dust.read(x, y)
    return (dust_id)
end

@view
func get_ship_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
) -> (ship : felt):
    let (ship : felt) = grid_ship.read(x, y)
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

    # We reached the last cell, this is the end
    let (x_outside) = is_le(size, x)  # x >= size
    if x_outside == TRUE:
        return (Cell(Vector2(x, y), Uint256(0, 0), 0))
    end
    # We reached the end of the column, let's go to the next one
    let (y_outside) = is_le(size, y)  # y >= size
    if y_outside == TRUE:
        let (res : Cell) = get_first_non_empty_cell(x + 1, 0)
        return (res)
    end

    # If there is a ship, return it
    let (ship : felt) = grid_ship.read(x, y)
    if ship != 0:
        return (Cell(Vector2(x, y), Uint256(0, 0), ship))
    end

    # If there is some dust, return it
    let (local dust_id : Uint256) = grid_dust.read(x, y)
    let (no_dust) = uint256_eq(dust_id, Uint256(0, 0))
    if no_dust == FALSE:
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
    let (x_outside) = is_le(size, x)  # x >= size
    if x_outside == TRUE:
        return (Vector2(-1, -1))
    end
    # We reached the end of the column, let's go to the next one
    let (y_outside) = is_le(size, y)  # y >= size
    if y_outside == TRUE:
        let (res : Vector2) = get_first_empty_cell(x + 1, 0)
        return (res)
    end

    # If there is a ship, go to next cell
    let (ship : felt) = grid_ship.read(x, y)
    if ship != 0:
        let (res : Vector2) = get_first_empty_cell(x, y + 1)
        return (res)
    end

    # If there is some dust, go to next cell
    let (local dust_id : Uint256) = grid_dust.read(x, y)
    let (no_dust) = uint256_eq(dust_id, Uint256(0, 0))
    if no_dust == FALSE:
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
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner : felt):
    Ownable_initializer(owner=owner)
    return ()
end

@external
func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    dust_contract_address : felt, size : felt
):
    Ownable_only_owner()
    _only_not_initialized()
    dust_contract.write(dust_contract_address)
    grid_size.write(size)
    return ()
end

# ------------------
# EXTERNAL FUNCTIONS
# ------------------

# This function must be invoked to process the next turn of the game.
@external
func next_turn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    Ownable_only_owner()

    _spawn_dust()

    _move_dust(0, 0)
    _update_grid_dust(0, 0)

    _move_ships(0, 0)
    _update_grid_ships(0, 0)

    return ()
end

@external
func add_ship{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ship_contract : felt
):
    Ownable_only_owner()
    let (position : Vector2) = get_first_empty_cell(0, 0)
    next_turn_grid_ship.write(position.x, position.y, ship_contract)
    grid_ship.write(position.x, position.y, ship_contract)
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
    let (size) = grid_size.read()

    let (dust_contract_address) = dust_contract.read()

    # Create a new Dust at random position and with random direction
    let (token_id : Uint256) = IDustContract.mint_random_on_border(dust_contract_address, size)

    # Get created Dust metadata to retrieve its position
    let (dust : Dust) = IDustContract.metadata(dust_contract_address, token_id)

    let (internal_dust_id : Uint256) = _to_internal_dust_id(token_id)
    next_turn_grid_dust.write(dust.position.x, dust.position.y, internal_dust_id)
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

    let (local dust_id : Uint256) = grid_dust.read(x, y)

    # if there is no dust here, we go directly to the next cell
    let (no_dust) = uint256_eq(dust_id, Uint256(0, 0))
    if no_dust == TRUE:
        _move_dust(x, y + 1)
        return ()
    end

    # Compute token_id in NFT contract
    let (token_id : Uint256) = _to_external_dust_id(dust_id)

    # There is some dust here! Let's move it
    let (local dust_contract_address) = dust_contract.read()
    let (local moved_dust : Dust) = IDustContract.move(dust_contract_address, token_id)

    # As the dust position changed, we free its old position
    next_turn_grid_dust.write(x, y, Uint256(0, 0))

    # Check collision
    let (local other_dust_id : Uint256) = next_turn_grid_dust.read(
        moved_dust.position.x, moved_dust.position.y
    )
    let (local no_other_dust) = uint256_eq(other_dust_id, Uint256(0, 0))

    if no_other_dust == FALSE:
        # In case of collision, burn the current dust
        IDustContract.burn(dust_contract_address, token_id)
        # see https://www.cairo-lang.org/docs/how_cairo_works/builtins.html#revoked-implicit-arguments
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        # No collision. Update the dust position in the grid
        next_turn_grid_dust.write(moved_dust.position.x, moved_dust.position.y, dust_id)
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    # process the next cell
    _move_dust(x, y + 1)
    return ()
end

func _update_grid_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
):
    let (size) = grid_size.read()

    # We reached the last cell, this is the end
    if x == size:
        return ()
    end
    # We reached the end of the column, let's go to the next one
    if y == size:
        _update_grid_dust(x + 1, 0)
        return ()
    end

    let (dust_id : Uint256) = next_turn_grid_dust.read(x, y)
    grid_dust.write(x, y, dust_id)

    # process the next cell
    _update_grid_dust(x, y + 1)
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

    let (local ship : felt) = grid_ship.read(x, y)

    # if there is no ship here, we go directly to the next cell
    if ship == 0:
        _move_ships(x, y + 1)
        return ()
    end

    # Call ship contract
    let (local new_direction : Vector2) = IShip.move(ship)
    local nx : felt = x + new_direction.x
    local ny : felt = y + new_direction.y

    # Check borders
    if nx == -1:
        nx = x
    end
    if nx == size:
        nx = x
    end
    if ny == -1:
        ny = y
    end
    if ny == size:
        ny = y
    end

    # Check collision with other ship
    let (other_ship : felt) = next_turn_grid_ship.read(nx, ny)
    if other_ship != 0:
        nx = x
        ny = y
    end

    # Check collision with dust
    let (dust_id : Uint256) = grid_dust.read(nx, ny)
    let (no_dust) = uint256_eq(dust_id, Uint256(0, 0))
    if no_dust == FALSE:
        # transfer dust to the ship
        let (contract_address) = get_contract_address()
        let (dust_contract_address) = dust_contract.read()

        let (token_id : Uint256) = _to_external_dust_id(dust_id)
        IDustContract.safeTransferFrom(dust_contract_address, contract_address, ship, token_id)

        # remove dust from the grid
        grid_dust.write(nx, ny, Uint256(0, 0))
        next_turn_grid_dust.write(nx, ny, Uint256(0, 0))

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
    next_turn_grid_ship.write(x, y, 0)
    next_turn_grid_ship.write(nx, ny, ship)

    # process the next cell
    _move_ships(x, y + 1)
    return ()
end

func _update_grid_ships{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
):
    let (size) = grid_size.read()

    # We reached the last cell, this is the end
    if x == size:
        return ()
    end
    # We reached the end of the column, let's go to the next one
    if y == size:
        _update_grid_ships(x + 1, 0)
        return ()
    end

    let (ship : felt) = next_turn_grid_ship.read(x, y)
    grid_ship.write(x, y, ship)

    # process the next cell
    _update_grid_ships(x, y + 1)
    return ()
end
