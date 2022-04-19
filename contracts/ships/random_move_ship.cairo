%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_block_timestamp, get_block_number

from openzeppelin.introspection.ERC165 import ERC165_supports_interface, ERC165_register_interface

from contracts.models.common import Vector2
from contracts.core.library import MathUtils_random_direction

const IERC721_RECEIVER_ID = 0x150b7a02

# -----------
# CONSTRUCTOR
# -----------

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ERC165_register_interface(IERC721_RECEIVER_ID)
    return ()
end

# ---------
# FUNCTIONS
# ---------

@external
func move{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        new_direction : Vector2):
    let (block_timestamp) = get_block_timestamp()
    let (block_number) = get_block_number()
    let (random_direction) = MathUtils_random_direction(block_timestamp, block_number)

    return (new_direction=random_direction)
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
