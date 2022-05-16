%lang starknet

# Functions can take implicit arguments. You might have already encountered this with
# syscall_ptr: felt* for example.

# I AM NOT DONE

# TODO: fix the "implicit_sum" signature to make the test pass

func implicit_sum() -> (result : felt):
    return (a + b)
end

# Do not change the test
@external
func test_sum{syscall_ptr : felt*}():
    let a = 3
    let b = 5
    let (sum) = implicit_sum{a=a, b=b}()
    assert sum = 8

    return ()
end
