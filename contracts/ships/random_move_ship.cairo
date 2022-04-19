%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_block_timestamp, get_block_number

from openzeppelin.introspection.ERC165 import ERC165_supports_interface, ERC165_register_interface

from contracts.models.common import Vector2
from contracts.core.library import MathUtils_random_direction
from contracts.interfaces.irand import IRandom

const IERC721_RECEIVER_ID = 0x150b7a02

# ------------
# STORAGE VARS
# ------------

@storage_var
func random_contract() -> (random_contract : felt):
end

# -----------
# CONSTRUCTOR
# -----------

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        random_contract_address : felt):
    ERC165_register_interface(IERC721_RECEIVER_ID)
    random_contract.write(random_contract_address)
    return ()
end

# ---------
# FUNCTIONS
# ---------

@external
func move{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        new_direction : Vector2):
    let (random_contract_address) = random_contract.read()
    let (block_timestamp) = get_block_timestamp()
    let (r1, r2, _, _, _) = IRandom.generate_random_numbers(
        random_contract_address, block_timestamp)
    let (random_direction) = MathUtils_random_direction(r1, r2)

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
