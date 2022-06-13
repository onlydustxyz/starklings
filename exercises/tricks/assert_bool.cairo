%lang starknet

# Boolean assertions, such as "x OR y" for boolean felts, can also be implemented without conditionals.

# I AM NOT DONE

# TODO Implement the following boolean asserts without "if"

func assert_or(x, y):
    # FILL ME
    return ()
end

func assert_and(x, y):
    # FILL ME
    return ()
end

func assert_nor(x, y):
    # FILL ME
    return ()
end

func assert_xor(x, y):
    # FILL ME
    return ()
end

# Do not modify the tests
@external
func test_assert_or():
    assert_or(0, 1)
    assert_or(1, 0)
    assert_or(1, 1)
    return ()
end

@external
func test_assert_or_ko():
    %{ expect_revert() %}
    assert_or(0, 0)
    return ()
end

@external
func test_assert_and():
    assert_and(1, 1)
    return ()
end

@external
func test_assert_and_ko1():
    %{ expect_revert() %}
    assert_and(0, 0)
    return ()
end

@external
func test_assert_and_ko2():
    %{ expect_revert() %}
    assert_and(0, 1)
    return ()
end

@external
func test_assert_and_ko3():
    %{ expect_revert() %}
    assert_and(1, 0)
    return ()
end

@external
func test_assert_nor():
    assert_nor(0, 0)
    return ()
end

@external
func test_assert_nor_ko1():
    %{ expect_revert() %}
    assert_nor(0, 1)
    return ()
end

@external
func test_assert_nor_ko2():
    %{ expect_revert() %}
    assert_nor(1, 0)
    return ()
end

@external
func test_assert_nor_ko3():
    %{ expect_revert() %}
    assert_nor(1, 1)
    return ()
end

@external
func test_assert_xor():
    assert_xor(0, 1)
    assert_xor(1, 0)
    return ()
end

@external
func test_assert_xor_ko():
    %{ expect_revert() %}
    assert_xor(0, 0)
    return ()
end

@external
func test_assert_xor_ko2():
    %{ expect_revert() %}
    assert_xor(1, 1)
    return ()
end
