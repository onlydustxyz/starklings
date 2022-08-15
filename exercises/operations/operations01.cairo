%lang starknet

# Felts are integers defined in the range [0 ; P[, all compuations are done modulo P.
# They can be unsigned integers using `let` or signed integers using `const`.
# Exercice resources: https://www.cairo-lang.org/docs/how_cairo_works/cairo_intro.html#field-elements

# I AM NOT DONE

# TODO
# Compute a number X which verify X + 1 < X using unsigned int
@external
func test_unsigned_integer():
    let x = 0  # Change only this line to make the test pass
    let z = x + 1
    %{ assert ids.z < ids.x, f'assert failed: {ids.z} >= {ids.x}' %}
    return ()
end

# TODO
# Compute a number Y which verify Y + 1 < Y using signed int
@external
func test_signed_integer():
    const y = 0  # Change only this line to make the test pass
    const z = y + 1
    %{ assert ids.z < ids.y, f'assert failed: {ids.z} >= {ids.y}' %}
    return ()
end
