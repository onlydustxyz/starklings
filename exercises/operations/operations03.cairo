%lang starknet

from starkware.cairo.common.math import assert_lt_felt

# Felts use prime number property to ensure (x / y) * y = x is always true.
# Even if `let` provide an unsigned integer, it is still possible to manage negative numbers thanks to field element properties.
# Exercice resources: https://www.cairo-lang.org/docs/how_cairo_works/cairo_intro.html#field-elements

# I AM NOT DONE

# TODO
# Set the value of x (in the hint) to verify the test
func solve() -> (x : felt):
    tempvar x
    %{ ids.x = -1 %}  # Change only this line to make the test pass
    return (x=x)
end

# Do not change the test
@external
func test_solve{range_check_ptr}():
    let (x) = solve()
    assert x = -17
    return ()
end
