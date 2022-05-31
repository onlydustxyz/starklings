%lang starknet

# References in Cairo are like aliases to specific memory cells pointed by ap

# I AM NOT DONE

# TODO: complete the bar function to make the test pass
# You will encounter a "revoked reference" error
# https://www.cairo-lang.org/docs/how_cairo_works/consts.html#revoked-references

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2

func foo(n):
    if n == 0:
        return ()
    end
    foo(n=n - 1)
    return ()
end

func bar{hash_ptr : HashBuiltin*}():
    hash2(1, 2)  # Do not change
    foo(3)  # Do not change

    # Insert something here to make the test pass

    hash2(3, 4)  # Do not change
    return ()  # Do not change
end

# Do not change the test
@external
func test_bar{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    bar{hash_ptr=pedersen_ptr}()

    return ()
end
