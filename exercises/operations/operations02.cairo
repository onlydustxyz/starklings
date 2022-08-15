%lang starknet

from starkware.cairo.common.math import assert_lt_felt, assert_not_zero

# Felts use prime number property to ensure (x / y) * y = x is always true.
# Since floats are not supported, this can lead to get surprising results.
# Exercice resources: https://www.cairo-lang.org/docs/how_cairo_works/cairo_intro.html#field-elements

# I AM NOT DONE

# TODO
# Find a number X which satisfy A / X > A with X in range ]0 ; 100]
func solve(a : felt) -> (x : felt):
    # TO FILL
    return (x=x)
end

# Do not change the test
@external
func test_solve{range_check_ptr}():
    let a = 347092984475551631116800
    let (x) = solve(a=a)
    assert_not_zero(x)
    assert_lt_felt(x, 101)
    assert_lt_felt(a, a / x)
    return ()
end
