%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.models.common import Vector2, Dust, Cell
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem

@storage_var
func grid_size() -> (size : felt):
end

@storage_var
func grid(position : Vector2) -> (cell : Cell):
end

@storage_var
func next_grid(position : Vector2) -> (cell : Cell):
end

func _get_grid_size{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        size : felt):
    let (size) = grid_size.read()
    return (size)
end

func _get_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt) -> (dust : Dust):
    let (cell : Cell) = grid.read(Vector2(x, y))
    return (dust=cell.dust)
end

func _get_ship_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt) -> (ship_id : felt):
    let (cell : Cell) = grid.read(Vector2(x, y))
    return (cell.ship_id)
end

func _get_next_turn_ship_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt) -> (ship_id : felt):
    let (cell : Cell) = next_grid.read(Vector2(x, y))
    return (cell.ship_id)
end

func _get_next_turn_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt) -> (dust : Dust):
    let (cell : Cell) = next_grid.read(Vector2(x, y))
    return (dust=cell.dust)
end

func _set_ship_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt, ship_id : felt):
    let position = Vector2(x, y)
    grid.write(position, Cell(Dust(FALSE, Vector2(0,0)), ship_id))
    return ()
end

func _set_next_turn_ship_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt, ship_id : felt):
    let position = Vector2(x, y)
    next_grid.write(position, Cell(Dust(FALSE, Vector2(0,0)), ship_id))
    return ()
end

func _set_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt, dust : Dust):
    let position = Vector2(x, y)
    grid.write(position, Cell(dust, 0))
    return ()
end

func _clear_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt):
    let position = Vector2(x, y)
    grid.write(position, Cell(Dust(FALSE, Vector2(0,0)), 0))
    return ()
end

func _set_next_turn_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt, dust : Dust):
    let position = Vector2(x, y)
    next_grid.write(position, Cell(dust, 0))
    return ()
end

func _clear_next_turn_dust_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        x : felt, y : felt):
    let position = Vector2(x, y)
    next_grid.write(position, Cell(Dust(FALSE, Vector2(0,0)), 0))
    return ()
end

func _get_grid_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        grid_state_len : felt, grid_state : Cell*):
    alloc_locals

    let (local grid_state : Cell*) = alloc()

    let (grid_state_len) = _rec_fill_grid_state(0, grid_state)

    return (grid_state_len, grid_state)
end

func _rec_fill_grid_state{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        grid_state_len : felt, grid_state : Cell*) -> (len : felt):
    let (size) = grid_size.read()
    if size * size == grid_state_len:
        return (grid_state_len)
    end

    let (y, x) = unsigned_div_rem(grid_state_len, size)
    let (cell : Cell) = grid.read(Vector2(x=x, y=y))

    assert grid_state[grid_state_len] = Cell(cell.dust, cell.ship_id)
    return _rec_fill_grid_state(grid_state_len + 1, grid_state)
end
