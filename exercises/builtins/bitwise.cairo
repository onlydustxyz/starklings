%lang starknet

from starkware.cairo.common.math import assert_le, assert_nn
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.bitwise import bitwise_and, bitwise_xor, bitwise_or
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.pow import pow

# While operations like addition, multiplication and divisions are native for felts,
# bit operations are more difficult to implement for felt.
# The bitwise builtin allows computing logical operations such as XOR, AND and OR on 251-bit felts.

# Resources:
# - https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/bitwise.cairo
# - https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/cairo_builtins.cairo#L17

# I AM NOT DONE

# TODO: Use a bitwise operation to return the n-th bit of the value parameter

func get_nth_bit{bitwise_ptr : BitwiseBuiltin*, range_check_ptr : felt}(value, n) -> (res):
    # FILL ME
    return (res)
end

# TODO: Use a bitwise operation to set the n-th bit of the value parameter to 1

func set_nth_bit{bitwise_ptr : BitwiseBuiltin*, range_check_ptr : felt}(value, n) -> (res):
    # FILL ME
    return (res)
end

# TODO: Use a bitwise operation to toggle the n-th bit of the value parameter

func toggle_nth_bit{bitwise_ptr : BitwiseBuiltin*, range_check_ptr : felt}(value, n) -> (res):
    # FILL ME
    return (res)
end

# Let's write a unique function that combines all the functions above.
# This function should use the bitwise_ptr explicitly.
# In particular, do not use any of the functions above.

# TODO: Write a function that takes as argument
#        - a felt `op` in ['get', 'set', 'toggle'],
#        - felts `value` and `n`,
#       and returns the result of the operation applied to `n`-th bit of value.
# Make sure
#   - the argument `n` is within the correct bitwise bounds,
#   - the `op` argument is correct.

func op_nth_bit{bitwise_ptr : BitwiseBuiltin*, range_check_ptr : felt}(op, value, n) -> (res):
    alloc_locals

    # Assert op is correct

    with_attr error_message("Bad bitwise bounds"):
        # Assert n is within bounds
    end

    # Compute the operation
    # Don't forget to advance bitwise_ptr

    return (res)
end

# Do not modify the tests.
@view
func test_get_nth_bit{syscall_ptr : felt*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr : felt}():
    alloc_locals
    local value = 0xA8
    let (local r0) = get_nth_bit(value, 0)
    let (local r1) = get_nth_bit(value, 1)
    let (local r2) = get_nth_bit(value, 2)
    let (local r3) = get_nth_bit(value, 3)
    let (local r4) = get_nth_bit(value, 4)
    let (local r5) = get_nth_bit(value, 5)
    let (local r6) = get_nth_bit(value, 6)
    let (local r7) = get_nth_bit(value, 7)
    assert r0 * 2 ** 0 + r1 * 2 ** 1 + r2 * 2 ** 2 + r3 * 2 ** 3 + r4 * 2 ** 4 + r5 * 2 ** 5 + r6 * 2 ** 6 + r7 * 2 ** 7 = value
    return ()
end

@view
func test_set_nth_bit{syscall_ptr : felt*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr : felt}():
    alloc_locals
    local value = 0
    let (local r0) = set_nth_bit(value, 0)
    assert 1 = r0
    let (local r1) = set_nth_bit(r0, 1)
    assert 3 = r1
    let (local r2) = set_nth_bit(r1, 2)
    assert 7 = r2
    let (local r3) = set_nth_bit(r2, 3)
    assert 15 = r3
    let (local r4) = set_nth_bit(r3, 4)
    assert 31 = r4
    let (local r5) = set_nth_bit(r4, 5)
    assert 63 = r5
    let (local r6) = set_nth_bit(r5, 6)
    assert 127 = r6
    let (local r7) = set_nth_bit(r6, 7)
    assert 255 = r7
    return ()
end

@view
func test_toggle_nth_bit{
    syscall_ptr : felt*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr : felt
}():
    alloc_locals

    local value = nondet %{ int('100000011010111', 2) %}
    let (res) = toggle_nth_bit(value, 14)
    let (res) = toggle_nth_bit(res, 3)
    let (res) = toggle_nth_bit(res, 5)
    assert res = 2 ** 8 - 1
    return ()
end

@view
func test_op_nth_bit{syscall_ptr : felt*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr : felt}():
    alloc_locals
    local v0
    local v1
    local v2
    local n0
    local n1
    local n2
    local r0
    local r1
    local r2
    %{
        from random import randint
        size = 249
        ids.v0 = randint(0,2**size) + 2**size
        tmpv1 = randint(0,2**size) + 2**size
        ids.v2 = randint(0,2**size) + 2**size
        ids.n0 = randint(0,size)
        ids.n1 = randint(0,size)
        ids.n2 = randint(0,size)
        ids.v1 = tmpv1 ^ (1 << ids.n1) if ((tmpv1 >> ids.n1) & 1) == 1 else tmpv1
        ids.r0 = (ids.v0 >> ids.n0) & 1
        ids.r1 = ids.v1 | (1 << ids.n1) 
        ids.r2 = ids.v2 ^ (1 << ids.n2)
    %}
    let (val0) = op_nth_bit('get', v0, n0)
    assert r0 = val0
    let (val1) = op_nth_bit('set', v1, n1)
    assert r1 = val1
    let (val2) = op_nth_bit('toggle', v2, n2)
    assert r2 = val2

    %{ expect_revert() %}
    let (_) = op_nth_bit('rigged', v0, n1)
    return ()
end

@view
func test_bitwise_bounds_negative_ko{
    syscall_ptr : felt*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr : felt
}():
    alloc_locals
    %{ expect_revert(error_message="Bad bitwise bounds") %}
    let (res) = op_nth_bit('set', 1337, -42)
    return ()
end

@view
func test_bitwise_bounds_too_high_ko{
    syscall_ptr : felt*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr : felt
}():
    alloc_locals
    %{ expect_revert(error_message="Bad bitwise bounds") %}
    let (res) = op_nth_bit('set', 1337, 251)
    return ()
end
