%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.models.common import Vector2, Dust, Cell, Context
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem

func _get_grid_size{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}() -> (
        size : felt):
    return (context.grid_size)
end

func _get_dust_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt) -> (dust : Dust):
    let (cell) = _get_cell_at(x, y)
    return (dust=cell.dust)
end

func _get_ship_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt) -> (ship_id : felt):
    let (cell) = _get_cell_at(x, y)
    return (cell.ship_id)
end

func _get_next_turn_ship_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt) -> (ship_id : felt):
    let (cell) = _get_next_cell_at(x, y)
    return (cell.ship_id)
end

func _get_next_turn_dust_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt) -> (dust : Dust):
    let (cell) = _get_next_cell_at(x, y)
    return (dust=cell.dust)
end

func _set_ship_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt, ship_id : felt):
    _set_cell_at(x, y, Cell(Dust(FALSE, Vector2(0, 0)), ship_id))
    return ()
end

func _set_next_turn_ship_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt, ship_id : felt):
    _set_next_cell_at(x, y, Cell(Dust(FALSE, Vector2(0, 0)), ship_id))
    return ()
end

func _set_dust_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt, dust : Dust):
    _set_cell_at(x, y, Cell(dust, 0))
    return ()
end

func _clear_dust_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt):
    _set_cell_at(x, y, Cell(Dust(FALSE, Vector2(0, 0)), 0))
    return ()
end

func _set_next_turn_dust_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt, dust : Dust):
    _set_next_cell_at(x, y, Cell(dust, 0))
    return ()
end

func _clear_next_turn_dust_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt):
    _set_next_cell_at(x, y, Cell(Dust(FALSE, Vector2(0, 0)), 0))
    return ()
end

func _get_grid_state{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}() -> (
        grid_state_len : felt, grid_state : Cell*):
    alloc_locals

    let (local grid_state : Cell*) = alloc()

    let (grid_state_len) = _rec_fill_grid_state(0, grid_state)

    return (grid_state_len, grid_state)
end

func _rec_fill_grid_state{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        grid_state_len : felt, grid_state : Cell*) -> (len : felt):
    let size = context.grid_size
    if size * size == grid_state_len:
        return (grid_state_len)
    end

    let (y, x) = unsigned_div_rem(grid_state_len, size)
    let (cell) = _get_cell_at(x, y)

    assert grid_state[grid_state_len] = Cell(cell.dust, cell.ship_id)
    return _rec_fill_grid_state(grid_state_len + 1, grid_state)
end

func _to_grid_index{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt) -> (index : felt):
    return (y * context.grid_size + x)
end

func _set_cell_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt, new_cell : Cell):
    alloc_locals
    let (index) = _to_grid_index(x, y)

    local new_context : Context
    let grid : Cell* = alloc()
    assert new_context.grid_size = context.grid_size
    assert new_context.grid = grid
    assert new_context.next_grid = context.next_grid
    assert new_context.max_turn_count = context.max_turn_count
    assert new_context.max_dust = context.max_dust
    assert new_context.rand_contract = context.rand_contract
    assert new_context.ships_len = context.ships_len
    assert new_context.ships = context.ships

    _get_updated_grid(
        new_context.grid_size * new_context.grid_size, new_context.grid, index, new_cell)
    let context = new_context
    return ()
end

func _set_next_cell_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt, new_cell : Cell):
    alloc_locals
    let (index) = _to_grid_index(x, y)

    local new_context : Context
    let next_grid : Cell* = alloc()
    assert new_context.grid_size = context.grid_size
    assert new_context.grid = context.grid
    assert new_context.next_grid = next_grid
    assert new_context.max_turn_count = context.max_turn_count
    assert new_context.max_dust = context.max_dust
    assert new_context.rand_contract = context.rand_contract
    assert new_context.ships_len = context.ships_len
    assert new_context.ships = context.ships

    _get_updated_grid(
        new_context.grid_size * new_context.grid_size, new_context.next_grid, index, new_cell)
    let context = new_context
    return ()
end

func _get_updated_grid{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        grid_len : felt, grid : Cell*, index : felt, new_cell : Cell):
    if grid_len == 0:
        return ()
    end

    if index == context.grid_size * context.grid_size - grid_len:
        assert [grid] = new_cell
    else:
        assert [grid] = [context.grid + index * Cell.SIZE]
    end
    # %{ print("grid_len={} content.grid_size={} ".format(ids.grid_len)) %}

    return _get_updated_grid(grid_len - 1, grid + Cell.SIZE, index, new_cell)
end

func _get_cell_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt) -> (cell : Cell):
    # %{ print('Get cell at({},{}) with grid size: {}'.format(ids.x, ids.y, ids.context.grid_size)) %}
    let (index) = _to_grid_index(x, y)
    # %{ print("Index: {}".format(ids.index)) %}
    let cell = [context.grid + index * Cell.SIZE]
    return (cell)
end

func _get_next_cell_at{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}(
        x : felt, y : felt) -> (cell : Cell):
    # %{ print('Get next cell at({},{}) with grid size: {}'.format(ids.x, ids.y, ids.context.grid_size)) %}
    let (index) = _to_grid_index(x, y)
    # %{ print("Index: {}".format(ids.index)) %}
    let cell = [context.next_grid + index * Cell.SIZE]
    return (cell)
end

func _init_grid{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        grid_len : felt, grid : Cell*):
    if grid_len == 0:
        return ()
    end

    assert [grid] = Cell(Dust(FALSE, Vector2(0, 0)), 0)

    _init_grid(grid_len - 1, grid + Cell.SIZE)
    return ()
end

func _increment_ship_score{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context,
        scores : felt*}(ship_id : felt):
    alloc_locals

    let (local new_scores : felt*) = alloc()
    _get_incremented_scores(context.ships_len, ship_id, new_scores)

    let scores = new_scores
    return ()
end

func _get_incremented_scores{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context,
        scores : felt*}(ships_len : felt, ship_id : felt, new_scores : felt*):
    if ships_len == 0:
        return ()
    end

    if ship_id == context.ships_len - ships_len + 1:
        assert [new_scores] = [scores + ship_id - 1] + 1
    else:
        assert [new_scores] = [scores + ship_id - 1]
    end

    return _get_incremented_scores(ships_len - 1, ship_id, new_scores + 1)
end

func _sync_two_grids{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, context : Context}():
    alloc_locals

    local new_context : Context
    let new_grid: Cell* = alloc()

    assert new_context.grid_size = context.grid_size
    assert new_context.grid = context.next_grid 
    assert new_context.next_grid = new_grid
    assert new_context.max_turn_count = context.max_turn_count
    assert new_context.max_dust = context.max_dust
    assert new_context.rand_contract = context.rand_contract
    assert new_context.ships_len = context.ships_len
    assert new_context.ships = context.ships
    
    _init_grid(context.grid_size * context.grid_size, new_context.next_grid)
    
    let context = new_context
    return ()
end