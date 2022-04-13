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

struct SeqEntry:
    member r1 : felt
    member r2 : felt
    member r3 : felt
    member r4 : felt
    member r5 : felt
end

# ------------
# STORAGE VARS
# ------------

@storage_var
func sequence(idx : felt) -> (entry : SeqEntry):
end

@storage_var
func counter() -> (count : felt):
end

# -----------
# CONSTRUCTOR
# -----------

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    sequence.write(0, SeqEntry(1, 2, 0, 1, 0))
    sequence.write(1, SeqEntry(1, 0, 0, 4, 0))
    sequence.write(2, SeqEntry(1, 2, 5, 1, 0))
    return ()
end

# -----
# VIEWS
# -----

@view
func generate_random_numbers{
    pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(salt : felt) -> (r1, r2, r3, r4, r5):
    let (count) = counter.read()
    counter.write(count + 1)
    let (e : SeqEntry) = sequence.read(count)
    return (e.r1, e.r2, e.r3, e.r4, e.r5)
end
