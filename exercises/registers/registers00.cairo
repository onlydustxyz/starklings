%lang starknet

# I AM NOT DONE

# Ressources
# https://www.cairo-lang.org/docs/how_cairo_works/cairo_intro.html#registers
# https://www.cairo-lang.org/docs/how_cairo_works/functions.html#function-arguments-and-return-values

# TODO
# Rewrite this function body in a high level syntax
@external
func ret_42() -> (r : felt):
    # [ap] = 42; ap++
    # ret
end

# TODO
# Rewrite this function body in a low level syntax, using registers
@external
func ret_0_and_1() -> (zero : felt, one : felt):
    # return (0, 1)
end

#########
# TESTS #
#########

@external
func test_ret_42():
    let (r) = ret_42()
    assert r = 42

    return ()
end

@external
func test_0_and_1():
    let (zero, one) = ret_0_and_1()
    assert zero = 0
    assert one = 1

    return ()
end
