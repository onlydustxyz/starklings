# Declare this file as a StarkNet contract.
%lang starknet

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

from contracts.models.dust import Vector2, Dust
from contracts.interfaces.dust import IDustContract

# ------------
# STORAGE VARS
# ------------
@storage_var
func grid_size() -> (size : felt):
end

@storage_var
func grid_dust(x : felt, y : felt) -> (dust_id : Uint256):
end

@storage_var
func grid_moved_dust(x : felt, y : felt) -> (dust_id : Uint256):
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
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    return ()
end

@external
func init{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    dust_contract_address : felt, size : felt
):
    dust_contract.write(dust_contract_address)
    grid_size.write(size)
    return ()
end

@external
func next_turn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    _spawn_dust()
    _move_dust(0, 0)
    _update_grid_dust(0, 0)
    return ()
end

func _spawn_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (size) = grid_size.read()

    # TODO: randomize position and direction
    local position : Vector2 = Vector2(1, 1)
    let dust : Dust = Dust(space_size=size, position=position, direction=Vector2(1, 0))

    let (dust_contract_address) = dust_contract.read()
    let (new_dust_id : Uint256) = IDustContract.mint(dust_contract_address, dust)

    let (new_dust_id_inc : Uint256, _) = uint256_add(new_dust_id, Uint256(1, 0))
    grid_dust.write(position.x, position.y, new_dust_id_inc)
    return ()
end

func _move_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x : felt, y : felt
):
    alloc_locals
    let (size) = grid_size.read()

    # We reached the last cell, this is the end
    if x == size:
        return ()
    end
    # We reach the end of the column, let's go to the next one
    if y == size:
        _move_dust(x + 1, 0)
        return ()
    end

    let (local dust_id : Uint256) = grid_dust.read(x, y)

    # if there is no dust here, we go directly to the next cell
    let (no_dust) = uint256_eq(dust_id, Uint256(0, 0))
    if no_dust == 1:
        _move_dust(x, y + 1)
        return ()
    end

    # Compute token_id in NFT contract
    let (local dust_id_nft : Uint256) = uint256_sub(dust_id, Uint256(1, 0))

    # There is some dust here! Let's move it
    let (local dust_contract_address) = dust_contract.read()
    let (local moved_dust : Dust) = IDustContract.move(dust_contract_address, dust_id_nft)

    # Check collision
    let (other_dust_id : Uint256) = grid_dust.read(moved_dust.position.x, moved_dust.position.y)
    let (no_other_dust) = uint256_eq(other_dust_id, Uint256(0, 0))

    if no_other_dust == 0:
        # In case of collision, burn the current dust
        IDustContract.burn(dust_contract_address, dust_id_nft)
        # see https://www.cairo-lang.org/docs/how_cairo_works/builtins.html#revoked-implicit-arguments
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        # No collision. Update the dust position in the grid
        grid_moved_dust.write(moved_dust.position.x, moved_dust.position.y, dust_id)
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
    alloc_locals
    let (size) = grid_size.read()

    # We reached the last cell, this is the end
    if x == size:
        return ()
    end
    # We reach the end of the column, let's go to the next one
    if y == size:
        _update_grid_dust(x + 1, 0)
        return ()
    end

    let (local dust_id : Uint256) = grid_moved_dust.read(x, y)
    grid_moved_dust.write(x, y, Uint256(0, 0))
    grid_dust.write(x, y, dust_id)

    # process the next cell
    _update_grid_dust(x, y + 1)
    return ()
end
