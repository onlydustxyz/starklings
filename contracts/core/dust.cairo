%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem, assert_lt
from starkware.cairo.common.uint256 import Uint256, uint256_add
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.token.erc721.library import (
    ERC721_name,
    ERC721_symbol,
    ERC721_balanceOf,
    ERC721_ownerOf,
    ERC721_isApprovedForAll,
    ERC721_setApprovalForAll,
    ERC721_initializer,
)
from openzeppelin.token.erc721_enumerable.library import (
    ERC721_Enumerable_initializer,
    ERC721_Enumerable_safeTransferFrom,
    ERC721_Enumerable_mint,
    ERC721_Enumerable_burn,
)

from openzeppelin.introspection.ERC165 import ERC165_supports_interface

from openzeppelin.access.ownable import Ownable_initializer, Ownable_only_owner

from contracts.models.common import Dust, Vector2
from contracts.interfaces.irand import IRandom

#
# Storage
#
@storage_var
func token_count() -> (token_count : Uint256):
end

struct Metadata:
    member space_size : felt
    member position : felt
    member direction : felt
end

@storage_var
func token_metadatas(token_id : Uint256) -> (metadata : Metadata):
end

@storage_var
func rand_contract() -> (rand_contract : felt):
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, rand_contract_address : felt
):
    ERC721_initializer(name='Dust Non Fungible Token', symbol='DUST')
    ERC721_Enumerable_initializer()
    Ownable_initializer(owner=owner)
    rand_contract.write(rand_contract_address)
    return ()
end

#
# Getters
#

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = ERC721_name()
    return (name)
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    let (symbol) = ERC721_symbol()
    return (symbol)
end

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner : felt) -> (
    balance : Uint256
):
    let (balance : Uint256) = ERC721_balanceOf(owner)
    return (balance)
end

@view
func ownerOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    tokenId : Uint256
) -> (owner : felt):
    let (owner : felt) = ERC721_ownerOf(tokenId)
    return (owner)
end

@view
func isApprovedForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, operator : felt
) -> (isApproved : felt):
    let (isApproved : felt) = ERC721_isApprovedForAll(owner, operator)
    return (isApproved)
end

@view
func metadata{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (metadata : Dust):
    let (metadata : Metadata) = token_metadatas.read(token_id)
    let (dust : Dust) = _to_dust(metadata)
    return (metadata=dust)
end

#
# Externals
#

@external
func setApprovalForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    operator : felt, approved : felt
):
    ERC721_setApprovalForAll(operator, approved)
    return ()
end

@external
func safeTransferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    from_ : felt, to : felt, tokenId : Uint256
):
    let (data : felt*) = alloc()
    ERC721_Enumerable_safeTransferFrom(from_, to, tokenId, 0, data)
    return ()
end

@external
func mint{
    pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(dust : Dust) -> (token_id : Uint256):
    alloc_locals
    Ownable_only_owner()

    # Mint token
    let (caller) = get_caller_address()
    let (local token_id : Uint256) = token_count.read()
    ERC721_Enumerable_mint(caller, token_id)

    # Increase latest token id
    let (incremented_token_count : Uint256, _) = uint256_add(token_id, Uint256(1, 0))
    token_count.write(incremented_token_count)

    # Store metadata
    let (metadata : Metadata) = _from_dust(dust)
    token_metadatas.write(token_id, metadata)

    return (token_id=token_id)
end

@external
func mint_random_on_border{
    pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(space_size : felt) -> (token_id : Uint256):
    let (metadata : Dust) = _generate_random_metadata_on_border(space_size)
    return mint(metadata)
end

@external
func mint_batch{
    pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(metadatas_len : felt, metadatas : Dust*) -> (token_ids_len : felt, token_ids : Uint256*):
    alloc_locals
    let (local token_ids : Uint256*) = alloc()
    _mint_batch_loop(metadatas_len, metadatas, token_ids)
    return (metadatas_len, token_ids)
end

@external
func mint_batch_random_on_border{
    pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(space_size : felt, token_count : felt) -> (token_ids_len : felt, token_ids : Uint256*):
    alloc_locals

    let (local token_ids : Uint256*) = alloc()
    _mint_random_on_border_loop(space_size, token_count, token_ids)

    return (token_count, token_ids)
end

func _mint_random_on_border_loop{
    pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(space_size : felt, token_ids_len : felt, token_ids : Uint256*):
    if token_ids_len == 0:
        return ()
    end

    let (token_id) = mint_random_on_border(space_size)
    assert [token_ids] = token_id

    _mint_random_on_border_loop(space_size, token_ids_len - 1, token_ids + Uint256.SIZE)
    return ()
end

@external
func burn{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(token_id : Uint256):
    Ownable_only_owner()

    # Mint token
    ERC721_Enumerable_burn(token_id)

    return ()
end

@external
func move{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    token_id : Uint256
) -> (metadata : Dust):
    alloc_locals
    Ownable_only_owner()

    let (current_metadata : Metadata) = token_metadatas.read(token_id)
    let (current_dust : Dust) = _to_dust(current_metadata)
    let (new_dust : Dust) = _move(current_dust)

    let (new_metadata : Metadata) = _from_dust(new_dust)
    token_metadatas.write(token_id, new_metadata)

    return (new_dust)
end

func _mint_batch_loop{
    pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(metadatas_len : felt, metadatas : Dust*, next_token : Uint256*):
    if metadatas_len == 0:
        return ()
    end

    let (token_id : Uint256) = mint([metadatas])
    assert [next_token] = token_id
    _mint_batch_loop(metadatas_len - 1, metadatas + Dust.SIZE, next_token + Uint256.SIZE)
    return ()
end

func _move{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(dust : Dust) -> (
    dust : Dust
):
    alloc_locals

    let (new_hdir) = _get_new_hdir(dust)
    let (new_vdir) = _get_new_vdir(dust)

    let new_x = dust.position.x + new_hdir
    let new_y = dust.position.y + new_vdir

    local new_dust : Dust
    assert new_dust.space_size = dust.space_size
    assert new_dust.position = Vector2(x=new_x, y=new_y)
    assert new_dust.direction = Vector2(x=new_hdir, y=new_vdir)

    return (dust=new_dust)
end

func _get_new_hdir{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    dust : Dust
) -> (hdir : felt):
    if dust.position.x == dust.space_size - 1:
        if dust.direction.x == 1:
            return (hdir=-1)
        end
    end

    if dust.position.x == 0:
        if dust.direction.x == -1:
            return (hdir=1)
        end
    end

    return (hdir=dust.direction.x)
end

func _get_new_vdir{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    dust : Dust
) -> (vdir : felt):
    if dust.position.y == dust.space_size - 1:
        if dust.direction.y == 1:
            return (vdir=-1)
        end
    end

    if dust.position.y == 0:
        if dust.direction.y == -1:
            return (vdir=1)
        end
    end

    return (vdir=dust.direction.y)
end

# Generate random metadata given a space size
func _generate_random_metadata_on_border{
    pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(space_size : felt) -> (metadata : Dust):
    alloc_locals
    local metadata : Dust
    assert metadata.space_size = space_size

    let (last_token_id) = token_count.read()
    let (rand_contract_address) = rand_contract.read()
    let (r1, r2, r3, r4, r5) = IRandom.generate_random_numbers(
        rand_contract_address, last_token_id.low
    )

    let (direction : Vector2) = _generate_random_direction(r1, r2)
    assert metadata.direction = direction

    let (position : Vector2) = _generate_random_position_on_border(space_size, r3, r4, r5)
    assert metadata.position = position

    return (metadata=metadata)
end

# Generate a random direction x, y where x,y are wither -1, 0 or 1
func _generate_random_direction{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    r1, r2
) -> (direction : Vector2):
    alloc_locals
    local direction : Vector2

    let (random) = _set_in_range(r1, -1, 1)
    assert direction.x = random

    let (random) = _set_in_range(r2, -1, 1)
    assert direction.y = random

    return (direction=direction)
end

# Generate a random position on a given border (top, left, right, bottom)
func _generate_random_position_on_border{
    pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr
}(space_size : felt, r1, r2, r3) -> (position : Vector2):
    alloc_locals

    # x is 0 or space_size - 1
    let (x) = _set_in_range(r1, 0, 1)
    local x = x * (space_size - 1)

    # y is in [0, space_size-1]
    let (y) = _set_in_range(r2, 0, space_size - 1)

    return _shuffled_position(x, y, r3)
end

# given x, y return randomly Position(x,y) or Position(y,x)
func _shuffled_position{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    x : felt, y : felt, r
) -> (position : Vector2):
    alloc_locals
    local position : Vector2

    let (on_horizontal_border) = _set_in_range(r, 0, 1)
    if on_horizontal_border == 0:
        assert position.x = x
        assert position.y = y
    else:
        assert position.x = y
        assert position.y = x
    end

    return (position=position)
end

# generate a random number x where min <= x <= max
func _set_in_range{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    value, min : felt, max : felt
) -> (value : felt):
    assert_lt(min, max)  # min < max

    let range = max - min + 1
    let (_, value) = unsigned_div_rem(value, range)  # random in [0, max-min]
    return (value + min)  # random in [min, max]
end

func _from_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(dust : Dust) -> (
    metadata : Metadata
):
    alloc_locals

    local metadata : Metadata
    assert metadata.space_size = dust.space_size
    assert metadata.position = dust.position.x * dust.space_size + dust.position.y
    assert metadata.direction = (dust.direction.x + 1) * 3 + (dust.direction.y + 1)

    return (metadata)
end

func _to_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    metadata : Metadata
) -> (dust : Dust):
    alloc_locals

    local dust : Dust
    assert dust.space_size = metadata.space_size

    let (x, y) = unsigned_div_rem(metadata.position, metadata.space_size)
    assert dust.position.x = x
    assert dust.position.y = y

    let (x, y) = unsigned_div_rem(metadata.direction, 3)

    assert dust.direction.x = x - 1
    assert dust.direction.y = y - 1

    return (dust)
end
