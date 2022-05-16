%lang starknet

# What is really neat with implicit arguments is that they are returned implicitly by any function using them
# This is a very powerful feature of the language since it helps with readability, letting the developer omit
# implicit arguments in the subsequent function calls.

# I AM NOT DONE

# TODO: fix the "child_function_1" and "child_function_2" signatures to make the test pass

# Do not change the function signature
func parent_function{a, b}() -> (result : felt):
    # Do not change the function body
    alloc_locals
    let (local intermediate_result_1) = child_function_1()
    let (local intermediate_result_2) = child_function_2()
    return (intermediate_result_1 + intermediate_result_2)
end

func child_function_1() -> (result : felt):
    # Do not change the function body
    return (2 * a)
end

func child_function_2() -> (result : felt):
    # Do not change the function body
    return (b + 3)
end

@external
func test_sum{syscall_ptr : felt*}():
    let a = 3
    let b = 5
    with a, b:
        let (result) = parent_function()
        assert result = 14
    end

    return ()
end
