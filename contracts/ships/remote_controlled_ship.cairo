%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from openzeppelin.introspection.ERC165 import ERC165_supports_interface, ERC165_register_interface
from openzeppelin.access.ownable import Ownable_initializer, Ownable_only_owner

from contracts.models.common import Vector2

const IERC721_RECEIVER_ID = 0x150b7a02

# ------------
# STORAGE VARS
# ------------

@storage_var
func current_direction() -> (direction : Vector2):
end

# -----------
# CONSTRUCTOR
# -----------

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner : felt):
    ERC165_register_interface(IERC721_RECEIVER_ID)
    Ownable_initializer(owner)
    current_direction.write(Vector2(0, 0))
    return ()
end

# ---------
# FUNCTIONS
# ---------

@external
func move{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        new_direction : Vector2):
    let (direction) = current_direction.read()
    return (new_direction=direction)
end

@external
func change_direction{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_direction : Vector2):
    Ownable_only_owner()
    current_direction.write(new_direction)
    return ()
end

@view
func supportsInterface{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        interfaceId : felt) -> (success : felt):
    let (success) = ERC165_supports_interface(interfaceId)
    return (success)
end

@view
func onERC721Received(
        operator : felt, from_ : felt, tokenId : Uint256, data_len : felt, data : felt*) -> (
        selector : felt):
    return (IERC721_RECEIVER_ID)
end
