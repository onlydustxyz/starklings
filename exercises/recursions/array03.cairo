%lang starknet

# There are multiple ways to scan through an array.
# Using recursion, one could go forwards or backwards.

# I AM NOT DONE

from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.alloc import alloc

# TODO
# Scan through the array elements from first to last
# Return 1 if elements of the array are in increasing order.
# Return 0 otherwise

func is_increasing{range_check_ptr : felt}(array : felt*, array_len : felt) -> (res : felt):
    if array_len == 0:
        return (1)
    end

    if array_len == 1:
        return (1)
    end

    let curr_value = 0
    let next_value = 0

    # Do not modify these lines
    let (is_sorted) = is_le(curr_value, next_value)
    if is_sorted == 1:
        return is_increasing(array + 1, array_len - 1)
    end

    return (0)
end

# TODO
# Scan through the array elements from last to first
# Return 1 if elements of the array are in decreasing order.
# Return 0 otherwise

func is_decreasing{range_check_ptr : felt}(array : felt*, array_len : felt) -> (res : felt):
    # FILL ME

    # Do not modify this line
    let (is_sorted) = is_le(curr_value, next_value)

    if is_sorted == 1:
        return is_decreasing(array, array_len)
    end

    return (0)
end

# TODO
# Use recursion to reverse array in rev_array
# Assume rev_array is already allocated

func reverse(array : felt*, rev_array : felt*, array_len : felt):
    # FILL ME
    return ()
end

# Do not modify the test
@external
func test_is_sorted{syscall_ptr : felt*, range_check_ptr : felt}():
    alloc_locals

    local inc_array : felt* = new (1, 2, 3, 4)
    local bad_array : felt* = new (1, 2, 69, -11, 0)
    local dec_array : felt* = new (10, 9, 8, 7, 6, 5)
    let (inc0) = is_increasing(inc_array, 4)
    let (inc1) = is_increasing(bad_array, 5)
    let (inc2) = is_increasing(dec_array, 6)
    assert (inc0, inc1, inc2) = (1, 0, 0)

    let (dec0) = is_decreasing(inc_array, 4)
    let (dec1) = is_decreasing(bad_array, 5)
    let (dec2) = is_decreasing(dec_array, 6)
    assert (dec0, dec1, dec2) = (0, 0, 1)

    return ()
end

# Do not modify the test
@external
func test_reversed{syscall_ptr : felt*}():
    alloc_locals

    local in_array : felt* = new (1, 2, 3, 4, 19, 42)
    let (reversed_array : felt*) = alloc()
    reverse(in_array, reversed_array, 6)
    assert 42 = [reversed_array + 0]
    assert 19 = [reversed_array + 1]
    assert 4 = [reversed_array + 2]
    assert 3 = [reversed_array + 3]
    assert 2 = [reversed_array + 4]
    assert 1 = [reversed_array + 5]

    local in_array : felt* = new (31337, 1664, 911, 0, -42)
    let (reversed_array : felt*) = alloc()
    reverse(in_array, reversed_array, 5)
    assert -42 = [reversed_array + 0]
    assert 0 = [reversed_array + 1]
    assert 911 = [reversed_array + 2]
    assert 1664 = [reversed_array + 3]
    assert 31337 = [reversed_array + 4]

    return ()
end
