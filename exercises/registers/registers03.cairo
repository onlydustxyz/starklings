%lang starknet

# I AM NOT DONE

# Cairo memory is immutable, which mean that once a memory cell have been assigned a value it be changed.
# The program will crash if someone try to assign a new, different, value to a already initialized memory cell.
# However, trying to assign twice, or more, a memory cell will the same value won't cause any harm.
#
# This property can be used to assert the value of a cell.
# By trying to give it a value to an already initialized memory cell, we can ensure that it already have this specific value,
# if it does not, the call fail

# TODO
# Rewrite this function in a high level syntax, using tempvar and assert
func crash():
    # [ap] = 42; ap++
    # [ap - 1] = 42
    # [ap - 1] = 21

    ret
end

# TODO
# Rewrite this funtion in a low level syntax
func assert_42(number : felt):
    # assert number = 42

    return ()
end

# TODO
# Write this function body so:
# if the memory cell pointed by `p_number` is not initialised, it set it to 42
# else if the value is initialized and different from 42, it crash
# else, do nothing and return
func assert_pointer_42(p_number : felt*):
    return ()
end

#########
# TESTS #
#########

from starkware.cairo.common.alloc import alloc

@external
func test_crash():
    %{ expect_revert() %}
    crash()

    return ()
end

@external
func test_assert_42():
    assert_42(42)

    %{ expect_revert() %}
    assert_42(21)

    return ()
end

@external
func test_assert_pointer_42_initialized():
    let (mem_zone : felt*) = alloc()
    assert mem_zone[0] = 42
    assert mem_zone[1] = 21

    assert_pointer_42(mem_zone)

    %{ expect_revert() %}
    assert_pointer_42(mem_zone + 1)

    return ()
end

@external
func test_assert_pointer_42_not_initialized_ok():
    let (mem_zone : felt*) = alloc()
    assert mem_zone[0] = 42
    assert_pointer_42(mem_zone)

    assert_pointer_42(mem_zone + 1)
    assert mem_zone[1] = 42

    return ()
end

@external
func test_assert_pointer_42_not_initialized_revert():
    let (mem_zone : felt*) = alloc()
    assert mem_zone[0] = 42
    assert_pointer_42(mem_zone)

    assert_pointer_42(mem_zone + 1)
    %{ expect_revert() %}
    assert mem_zone[1] = 21

    return ()
end
