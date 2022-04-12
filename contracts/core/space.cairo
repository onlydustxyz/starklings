# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from contracts.models.dust import Vector2, Dust
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

@contract_interface
namespace IDustContract:
    func move(dust_id : Uint256) -> (new_position : Vector2):
    end
    func burn(dust_id : Uint256):
    end
end

# ------------
# STORAGE VARS
# ------------
@storage_var
func grid_size() -> (size : Vector2):
end

@storage_var
func grid_dust(x : felt, y : felt) -> (dust_id : Uint256):
end

@storage_var
func dust_contract() -> (contract : felt):
end

@view
func get_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
) -> (dust_id : Uint256):
    let (dust_id : Uint256) = grid_dust.read(x, y)
    return (dust_id)
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    dust_contract_address : felt, size : felt
):
    dust_contract.write(dust_contract_address)
    grid_size.write(Vector2(size, size))
    return ()
end

@external
func next_turn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    _spawn_dust()
    _move_dust(0, 0)
    return ()
end

func _spawn_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # TODO: mint
    grid_dust.write(1, 1, Uint256(42, 0))
    return ()
end

func _move_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
):
    alloc_locals
    let (size : Vector2) = grid_size.read()

    # We reached the last cell, this is the end
    if x == size.x:
        return ()
    end
    # We reach the end of the column, let's go to the next one
    if y == size.y:
        _move_dust(x + 1, 0)
        return ()
    end

    let (local dust_id : Uint256) = grid_dust.read(x, y)

    # if there is no dust here, we go directly to the next cell
    let (dust_present) = uint256_eq(dust_id, Uint256(0, 0))
    if dust_present == 1:
        _move_dust(x, y + 1)
        return ()
    end

    # There is some dust here! Let's move it
    let (local dust_contract_address) = dust_contract.read()
    let (local new_position : Vector2) = IDustContract.move(dust_contract_address, dust_id)

    # Check collision
    let (other_dust_id : Uint256) = grid_dust.read(new_position.x, new_position.y)
    let (other_dust_present) = uint256_eq(other_dust_id, Uint256(0, 0))

    if other_dust_present == 0:
        # In case of collision, burn the current dust
        IDustContract.burn(dust_contract_address, dust_id)
        # see https://www.cairo-lang.org/docs/how_cairo_works/builtins.html#revoked-implicit-arguments
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        # No collision. Update the dust position in the grid
        grid_dust.write(new_position.x, new_position.y, dust_id)
        grid_dust.write(x, y, Uint256(0, 0))
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    # process the next cell
    _move_dust(x, y + 1)
    return ()
end
