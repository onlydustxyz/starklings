%lang starknet

# I AM NOT DONE

# Resource
# https://www.cairo-lang.org/docs/how_cairo_works/functions.html#function-arguments-and-return-values

# TODO
# Rewrite this function with a high level syntax
@external
func assert_is_42(n : felt):
    # [ap - 3] = 42
    # ret
end

# TODO
# Rewrite this function with a low level syntax, using registers
@external
func sum(a : felt, b : felt) -> (s : felt):
    # return (a + b)
end

#########
# TESTS #
#########

@external
func test_assert_is_42_ok():
    assert_is_42(42)
    return ()
end

@external
func test_assert_is_42_ko():
    %{ expect_revert() %}
    assert_is_42(21)
    return ()
end

@external
func test_sum():
    let (s) = sum(2, 3)
    assert s = 5
    return ()
end
