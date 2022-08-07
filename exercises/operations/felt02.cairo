%lang starknet

# Felts supports basic math operations.
# High level syntax allows one-line multiple operations while low level syntax doesn't.
# Exercice source: https://www.cairo-lang.org/docs/how_cairo_works/cairo_intro.html#field-elements

# I AM NOT DONE

# TODO
# Write this function body in a high level syntax
func poly_high_level(x : felt) -> (res : felt):
    # return x³ + 23x² + 45x + 67 according to x
    return (res=res)  # Do not change
end

# TODO
# Write this function body in a low level syntax (result must be stored in [ap - 1] before ret)
func poly_low_level(x : felt):
    # return x³ + 23x² + 45x + 67 according to x
    ret  # Do not change
end

# Do not change the test
@external
func test_poly():
    poly_low_level(x=100)
    assert [ap - 1] = 1234567
    let (high_level_res) = poly_high_level(x=100)
    assert high_level_res = 1234567
    return ()
end
