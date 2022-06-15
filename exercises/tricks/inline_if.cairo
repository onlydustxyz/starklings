%lang starknet

from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.bool import TRUE, FALSE

# Sometimes, conditionals can be avoided by using a polynomial that maps valid inputs to 0
# Use this trick to rewrite functions without "if"

# I AM NOT DONE

# TODO: Implement a ternary operator `if cond then return val_true else return val_false`
# Make sure the condition is a boolean

func if_then_else(cond : felt, val_true : felt, val_false) -> (res : felt):
    # FILL ME
    return (res)
end

@external
func test_ternary_conditional_operator():
    let (res) = if_then_else(FALSE, 911, 420)
    assert 420 = res
    let (res) = if_then_else(TRUE, 911, 'over 9000')
    assert 911 = res
    let (res) = if_then_else(FALSE, 69420, 1559)
    assert 1559 = res
    let (res) = if_then_else(TRUE, 'nice', 69)
    assert 'nice' = res
    %{ expect_revert() %}
    let (res) = if_then_else(69, 'nope', 911)
    return ()
end
