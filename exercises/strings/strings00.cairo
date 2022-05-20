%lang starknet

# Cairo supports short strings which are encoded as ASCII under the hood
# e.g. let hello_string = 'Hello'
#      let hello_string = 0x48656c6c6f
#      let hello_string = 310939249775

# I AM NOT DONE

# TODO: Fix the say_hello function by filling returning the appropriate short strings

func say_hello() -> (hello_string : felt, hello_felt : felt, hello_hex : felt):
    # FILL ME
    return (hello_string, hello_felt, hello_hex)
end

# Do not change the test
@external
func test_say_hello{syscall_ptr : felt*}():
    let (user_string, user_felt, user_hex) = say_hello()
    assert user_string = 'Hello Starklings'
    assert user_felt = 12011164701440182822452181791570417168947
    assert user_hex = 0x627569646c20627569646c20627569646c
    return ()
end
