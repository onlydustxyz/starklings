%lang starknet

# Fibonacci numbers are defined by the following recurrence:
# F(0) = 0
# F(1) = 1
# F(n) = F(n-1) + F(n-2)

# I AM NOT DONE

# TODO: write a recursive implementation of fibonacci numbers that returns the nth fibonacci number

func fibonacci(n : felt) -> (result : felt):
    return (0)
end

# Do not change the test
@external
func test_fibonacci{syscall_ptr : felt*}():
    let (n) = fibonacci(0)
    assert n = 0
    let (n) = fibonacci(1)
    assert n = 1
    let (n) = fibonacci(7)
    assert n = 13
    let (n) = fibonacci(10)
    assert n = 55
    return ()
end
