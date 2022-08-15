%lang starknet

# Felts supports basic math operations.
# Only accepted operators (const excluded) are: +, -, * and /

# I AM NOT DONE

# TODO
# Return the solution of (x² + x - 2) / (x - 2)
func poly(x : felt) -> (res : felt):
    # FILL ME
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
