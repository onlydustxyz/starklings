%lang starknet

# What to do in this exercise ?
#
# We will use the openzeppelin libraries to implement our own ERC721 token
# You will find some function definition in this file and have to implement their body.
# Nothing to hairy, just use the openzepelin provided functions

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
    ERC721_Enumerable_totalSupply,
)

from openzeppelin.introspection.ERC165 import ERC165_supports_interface

from openzeppelin.access.ownable import Ownable_initializer, Ownable_only_owner

from contracts.models.common import Dust, Vector2
from contracts.interfaces.irand import IRandom

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt,
):
    # TODO
    # Init the contract as an ERC721, symbol is `DUST`, name is `Dust Non Fungible Token` 
    # Init the contract as an ERC721 Enumerable 
    # Init the contract as Ownable 
    return ()
end

#
# Getters
#

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    # TODO
    # Return the name of the contract
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    # TODO
    # Return the symbol of the contract
end

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner : felt) -> (
    balance : Uint256
):
    # TODO
    # Return the balance of an user
end

@view
func ownerOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    tokenId : Uint256
) -> (owner : felt):
    # TODO
    # Return the owner of a token
end

@view
func isApprovedForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, operator : felt
) -> (isApproved : felt):
    # TODO
    # Return the approval status for an owner and an operator
end

#
# Externals
#

@external
func setApprovalForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    operator : felt, approved : felt
):
    # TODO
    # Set the approval for all of approved for operator 
    return ()
end

@external
func safeTransferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    from_ : felt, to : felt, tokenId : Uint256
):
    # TODO
    # Do a safe transfer of token
end

@external
func mint{
    pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(dust : Dust) -> (token_id : Uint256):
    alloc_locals
    
    # TODO
    # Restrict this call to `only_owner`
    # Mint the token
    # Return it's ID
end

@external
func burn{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(token_id : Uint256):
    # TODO
    # Restrict this call to `only_owner`
    # Burn token

    return ()
end