%lang starknet

# What to do in this exercise ?
#
# Write a peudo random function

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin, BitwiseBuiltin
from starkware.cairo.common.math import unsigned_div_rem, assert_lt
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.hash import hash2
from starkware.starknet.common.syscalls import (
    get_block_number,
    get_block_timestamp,
    get_caller_address,
    get_tx_info,
)

@view
func generate_random_numbers{
    pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(salt : felt) -> (random):
    # TODO
    # Return a "random" number
    # Sources of entropy you can use:
    # - the `salt` parameter
    # - the block number
    # - the block timestamp
    # - the transaction infos
    # 
    # Tip: using the hash2 function may help

    return (random)
end
