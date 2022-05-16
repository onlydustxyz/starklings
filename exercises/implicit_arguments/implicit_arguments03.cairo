%lang starknet

# What is really neat with implicit arguments is that they are returned implicitly by any function using them
# This is a very powerful feature of the language since it helps with readability, letting the developer omit
# implicit arguments in the subsequent function calls.

# I AM NOT DONE

# TODO: implement the "black_box" function body to make the test pass

# Do not change the function signature!
func black_box{secret : felt}() -> ():
    # Make the magic happen here :)
    return ()
end

# Do not change the test
@external
func test_secret_change{syscall_ptr : felt*}():
    let secret = 'no so secret'
    with secret:
        black_box()
        assert secret = 'very secret!'
    end

    return ()
end
