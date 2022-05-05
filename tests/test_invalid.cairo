%lang starknet

func sum_func{syscall_ptr : felt*, range_check_ptr}(a : felt, b : felt) -> (res : felt):
    return (a + b)
end

@external
func test_sum{syscall_ptr : felt*, range_check_ptr}():
    let (r) = sum_func(4, 3)
    assert r 
    return ()
end
