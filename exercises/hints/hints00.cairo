%lang starknet

# Hints

# Hints are the Cairo way to defer part of the program execution to an external program
# Memory can be accessed and assigned inside a hint by using variables identifiers.
# e.g., inside a hint variable `a` is accessed through `ids.a`

# I AM NOT DONE

# TODO: Assign the value of `res` inside a hint.

func basic_hint() -> (value : felt):
    alloc_locals
    local res
    # TODO: Insert hint here
    return (res)
end

# Do not change the test
@external
func test_basic_hint{syscall_ptr : felt*}():
    let (value) = basic_hint()
    assert 41 = value - 1
    return ()
end
