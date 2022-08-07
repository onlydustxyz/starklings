%lang starknet

# Felts supports basic math operations.
# Only accepted operators (const excluded) are: +, -, * and /

# I AM NOT DONE

# TODO
# Write this function body in a high level syntax
func poly(x : felt) -> (res : felt):
    # return (x² + x - 1) / (x - 2) according to x
    return (res=res)  # Do not change
end

# Do not change the test
@external
func test_poly():
    let (res) = poly(x=1)
    assert res = 0
    let (res) = poly(x=3)
    assert res = 10
    return ()
end
