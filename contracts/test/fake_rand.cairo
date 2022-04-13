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
}(salt : felt) -> (r1, r2, r3, r4, r5):
    let (random) = hash2{hash_ptr=pedersen_ptr}(salt, 12345)

    # Make sure random is not too big
    const ALL_ONES = 2 ** 128 - 1
    let (random) = bitwise_and(ALL_ONES, random)

    # Now let's split it as much as we need as this "random" will be the same for the whole transaction
    let (random, r1) = unsigned_div_rem(random, 2 ** 16 - 1)
    let (random, r2) = unsigned_div_rem(random, 2 ** 16 - 1)
    let (random, r3) = unsigned_div_rem(random, 2 ** 16 - 1)
    let (random, r4) = unsigned_div_rem(random, 2 ** 16 - 1)
    let (random, r5) = unsigned_div_rem(random, 2 ** 16 - 1)

    return (r1, r2, r3, r4, r5)
end
