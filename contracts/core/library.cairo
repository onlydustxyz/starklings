%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, assert_lt
from starkware.cairo.common.math_cmp import is_le
from contracts.models.common import Vector2

# clip a value to the interval [min, max]
func MathUtils_clamp_value{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        value, min : felt, max : felt) -> (value : felt):
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

# generate a random number x where min <= x <= max
func MathUtils_random_in_range{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        seed : felt, min : felt, max : felt) -> (random_value : felt):
    assert_lt(min, max)  # min < max

    let range = max - min + 1
    let (_, value) = unsigned_div_rem(seed, range)  # random in [0, max-min]
    return (value + min)  # random in [min, max]
end

# generate a random direction
func MathUtils_random_direction{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
        seed : felt) -> (random_direction : Vector2):
    alloc_locals
    local random_direction : Vector2

    let (random) = MathUtils_random_in_range(seed, -1, 1)
    assert random_direction.x = random

    let (random) = MathUtils_random_in_range(seed + 1, -1, 1)
    assert random_direction.y = random

    return (random_direction=random_direction)
end
