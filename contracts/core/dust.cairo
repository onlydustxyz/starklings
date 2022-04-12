%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256, uint256_add
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.token.erc721.library import (
    ERC721_name, ERC721_symbol, ERC721_balanceOf, ERC721_ownerOf, ERC721_isApprovedForAll,
    ERC721_initializer, ERC721_setApprovalForAll, ERC721_safeTransferFrom, ERC721_mint, ERC721_burn)

from openzeppelin.introspection.ERC165 import ERC165_supports_interface

from openzeppelin.access.ownable import Ownable_initializer, Ownable_only_owner

from contracts.models.dust import Dust, Vector2

#
# Storage
#
@storage_var
func nb_tokens() -> (nb_tokens : Uint256):
end

@storage_var
func token_metadatas(token_id : Uint256) -> (metadata : Dust):
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner : felt):
    ERC721_initializer(name='Dust Non Fungible Token', symbol='DUST')
    Ownable_initializer(owner=owner)
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
        balance : Uint256):
    let (balance : Uint256) = ERC721_balanceOf(owner)
    return (balance)
end

@view
func ownerOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        tokenId : Uint256) -> (owner : felt):
    let (owner : felt) = ERC721_ownerOf(tokenId)
    return (owner)
end

@view
func isApprovedForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner : felt, operator : felt) -> (isApproved : felt):
    let (isApproved : felt) = ERC721_isApprovedForAll(owner, operator)
    return (isApproved)
end

@view
func metadata{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        token_id : Uint256) -> (metadata : Dust):
    let (metadata : Dust) = token_metadatas.read(token_id)
    return (metadata=metadata)
end

#
# Externals
#

@external
func setApprovalForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        operator : felt, approved : felt):
    ERC721_setApprovalForAll(operator, approved)
    return ()
end

@external
func safeTransferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        from_ : felt, to : felt, tokenId : Uint256):
    let (data : felt*) = alloc()
    ERC721_safeTransferFrom(from_, to, tokenId, 0, data)
    return ()
end

@external
func mint{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(metadata : Dust) -> (
        token_id : Uint256):
    alloc_locals
    Ownable_only_owner()

    # Mint token
    let (caller) = get_caller_address()
    let (local token_id : Uint256) = nb_tokens.read()
    ERC721_mint(caller, token_id)

    # Increase latest token id
    let (nb_tokens_inc : Uint256, _) = uint256_add(token_id, Uint256(1, 0))
    nb_tokens.write(nb_tokens_inc)

    # Store metadata
    token_metadatas.write(token_id, metadata)

    return (token_id=token_id)
end

@external
func mint_batch{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        metadatas_len : felt, metadatas : Dust*) -> (token_id_len : felt, token_id : Uint256*):
    alloc_locals
    let (local token_ids : Uint256*) = alloc()
    _mint_batch_loop(metadatas_len, metadatas, token_ids)
    return (metadatas_len, token_ids)
end

@external
func burn{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(token_id : Uint256):
    Ownable_only_owner()

    # Mint token
    ERC721_burn(token_id)

    return ()
end

@external
func move{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        token_id : Uint256) -> (metadata : Dust):
    alloc_locals
    Ownable_only_owner()

    let (current_metadata : Dust) = token_metadatas.read(token_id)
    let (new_metadata : Dust) = _move(current_metadata)

    token_metadatas.write(token_id, new_metadata)

    return (new_metadata)
end

func _mint_batch_loop{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        metadatas_len : felt, metadatas : Dust*, next_token : Uint256*):
    if metadatas_len == 0:
        return ()
    end

    let (token_id : Uint256) = mint([metadatas])
    assert [next_token] = token_id
    _mint_batch_loop(metadatas_len - 1, metadatas + Dust.SIZE, next_token + Uint256.SIZE)
    return ()
end

func _move{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(dust : Dust) -> (
        dust : Dust):
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
        dust : Dust) -> (hdir : felt):
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
        dust : Dust) -> (vdir : felt):
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
