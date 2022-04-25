%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, assert_nn, sqrt, assert_le

from starkware.cairo.common.math_cmp import is_le, is_nn

from contracts.models.common import Vector2, Cell

# ---------
# EXTERNAL
# ---------

@external
func move{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        grid_len : felt, grid : Cell*, self : felt) -> (new_direction : Vector2):
    with grid_len, grid, self:
        let (new_direction) = _move()
    end
    return (new_direction=new_direction)
end

# ---------
# INTERNAL
# ---------
func _move{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}() -> (new_direction : Vector2):
    alloc_locals

    let (local my_position) = _find_me()
    with_attr error_message("I am lost in space"):
        assert_nn(my_position.x)
        assert_nn(my_position.y)
    end

    let (dust_position) = _find_nearest_dust(my_position)
    let (dust_found) = _found(dust_position)
    if dust_found == 0:
        return (new_direction=Vector2(0, 0))
    end

    return _compute_direction(my_position, dust_position)
end

func _find_me{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}() -> (position : Vector2):
    let (position) = _find_ship(self)
    return (position=position)
end

func _find_ship{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}(ship_id : felt) -> (position : Vector2):
    return _find_ship_loop(grid_len, grid, ship_id)
end

func _find_ship_loop{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}(
        current_grid_len : felt, current_grid : Cell*, ship_id : felt) -> (position : Vector2):
    if current_grid_len == 0:
        return (position=Vector2(-1, -1))  # Not found
    end

    let current_ship_id = [current_grid].ship_id
    if current_ship_id == ship_id:
        return _to_position(grid_len - current_grid_len)  # Found
    end

    return _find_ship_loop(current_grid_len - 1, current_grid + Cell.SIZE, ship_id)  # Keep searching
end

func _find_nearest_dust{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}(from_ : Vector2) -> (position : Vector2):
    return _find_nearest_dust_loop(grid_len, grid, from_, Vector2(-1, -1))
end

func _find_nearest_dust_loop{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}(
        current_grid_len : felt, current_grid : Cell*, from_ : Vector2, nearest_dust : Vector2) -> (
        position : Vector2):
    alloc_locals

    if current_grid_len == 0:
        return (position=nearest_dust)  # End of the grid
    end

    let (nearest_dust) = _try_select_nearest_dust(
        current_grid_len, current_grid, from_, nearest_dust)

    # Keep searching
    return _find_nearest_dust_loop(
        current_grid_len - 1, current_grid + Cell.SIZE, from_, nearest_dust)
end

func _try_select_nearest_dust{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}(
        current_grid_len : felt, current_grid : Cell*, from_ : Vector2, nearest_dust : Vector2) -> (
        new_nearest_dust : Vector2):
    if [current_grid].dust.present == 0:
        # No dust in current cell, keep the previous one
        return (new_nearest_dust=nearest_dust)
    end

    # Compare distances and pick the nearest one
    let (current_dust) = _to_position(grid_len - current_grid_len)
    let (nearest_dust) = _select_nearest_dust(from_, nearest_dust, current_dust)

    return (new_nearest_dust=nearest_dust)
end

func _select_nearest_dust{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}(
        from_ : Vector2, nearest_dust : Vector2, candidate_dust : Vector2) -> (position : Vector2):
    alloc_locals

    let (is_valid) = is_nn(nearest_dust.x)
    if is_valid == 0:
        return (position=candidate_dust)  # First dust found, keep it
    end

    let (local nearest_dust_distance) = _compute_distance(from_, nearest_dust)
    let (local candidate_dust_distance) = _compute_distance(from_, candidate_dust)

    let (is_closer) = is_le(candidate_dust_distance, nearest_dust_distance)
    if is_closer == 1:
        return (position=candidate_dust)  # The candidate is closer, keep it
    end

    return (position=nearest_dust)  # Otherwise keep the nearest one
end

func _to_position{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}(cell_id : felt) -> (position : Vector2):
    let (nb_rows) = sqrt(grid_len)
    with_attr error_message("Invalid grid size, should be perfect square"):
        assert_le(nb_rows, grid_len)
    end
    let (y, x) = unsigned_div_rem(cell_id, nb_rows)
    return (position=Vector2(x, y))
end

func _compute_direction{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}(from_ : Vector2, to_ : Vector2) -> (direction : Vector2):
    alloc_locals

    let (local x) = _get_linear_direction(from_.x, to_.x)
    let (y) = _get_linear_direction(from_.y, to_.y)

    return (direction=Vector2(x, y))
end

func _compute_distance{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}(from_ : Vector2, to_ : Vector2) -> (distance : felt):
    let dist_x = to_.x - from_.x
    let dist_y = to_.y - from_.y

    return (distance=dist_x * dist_x + dist_y * dist_y)
end

func _get_linear_direction{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}(from_ : felt, to_ : felt) -> (direction : felt):
    alloc_locals

    let (local towards) = is_le(from_, to_)
    let (back) = is_le(to_, from_)

    return (direction=towards - back)  # Will return -1 if need to go back, 1 if need to go towards, 0 if both are aligned
end

func _found{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, grid_len : felt,
        grid : Cell*, self : felt}(position : Vector2) -> (found : felt):
    alloc_locals

    let (local x_valid) = is_nn(position.x)
    let (y_valid) = is_nn(position.x)

    return (found=x_valid * y_valid)
end
