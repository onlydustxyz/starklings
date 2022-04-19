%lang starknet

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
    let (random) = hash2{hash_ptr=pedersen_ptr}(salt, 12345)

    let (block_number) = get_block_number()
    let (random) = hash2{hash_ptr=pedersen_ptr}(random, block_number + 98765)

    let (block_timestamp) = get_block_timestamp()
    let (random) = hash2{hash_ptr=pedersen_ptr}(random, block_timestamp + 55555)

    let (tx_info) = get_tx_info()
    let (random) = hash2{hash_ptr=pedersen_ptr}(random, tx_info.transaction_hash)

    # Make sure random is not too big
    const ALL_ONES = 2 ** 128 - 1
    let (random) = bitwise_and(ALL_ONES, random)


    return (random)
end
