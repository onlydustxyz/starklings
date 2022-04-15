%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, assert_lt
from starkware.cairo.common.math_cmp import is_le

func MathUtils_set_in_range{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    value, min : felt, max : felt
) -> (value : felt):
    assert_lt(min, max)  # min < max

    let (is_lower_than_min) = is_le(value, min)
    if is_lower_than_min == 1:
        return (min)
    end

    let (is_higher_than_max) = is_le(max, value)
    if is_higher_than_max == 1:
        return (max)
    end

    return (value)
end
