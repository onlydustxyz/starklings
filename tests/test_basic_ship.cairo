%lang starknet

from contracts.models.common import Cell, Vector2
from contracts.ships.basic_ship import move
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

@external
func test_no_move_if_no_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local grid : Cell*
    local grid_len : felt

    %{
        import sys, os
        sys.path.append(os.path.join(os.getcwd(), 'tests'))

        from helpers import empty_grid, store_grid
        grid = empty_grid(10)
        store_grid(grid, ids, segments, memory)
    %}

    %{ stop_expecting_revert = expect_revert(error_message="I am lost in space") %}
    let (direction) = move(grid_len, grid, 1)
    %{ stop_expecting_revert() %}

    return ()
end

@external
func test_move_towards_single_dust_above{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local grid : Cell*
    local grid_len : felt

    const SHIP_ID = 1

    %{
        import sys, os
        sys.path.append(os.path.join(os.getcwd(), 'tests'))

        from helpers import empty_grid, store_grid, dust_cell, ship_cell
        grid = empty_grid(10)
        grid[0][5] = dust_cell()
        grid[3][5] = ship_cell(ids.SHIP_ID)
        store_grid(grid, ids, segments, memory)
    %}

    let (direction) = move(grid_len, grid, 1)
    assert direction = Vector2(0, -1)

    return ()
end

@external
func test_move_towards_single_dust_below{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local grid : Cell*
    local grid_len : felt

    const SHIP_ID = 1

    %{
        import sys, os
        sys.path.append(os.path.join(os.getcwd(), 'tests'))

        from helpers import empty_grid, store_grid, dust_cell, ship_cell
        grid = empty_grid(10)
        grid[5][5] = dust_cell()
        grid[3][5] = ship_cell(ids.SHIP_ID)
        store_grid(grid, ids, segments, memory)
    %}

    let (direction) = move(grid_len, grid, 1)
    assert direction = Vector2(0, 1)

    return ()
end

@external
func test_move_towards_single_dust_on_the_left{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local grid : Cell*
    local grid_len : felt

    const SHIP_ID = 1

    %{
        import sys, os
        sys.path.append(os.path.join(os.getcwd(), 'tests'))

        from helpers import empty_grid, store_grid, dust_cell, ship_cell
        grid = empty_grid(10)
        grid[3][1] = dust_cell()
        grid[3][5] = ship_cell(ids.SHIP_ID)
        store_grid(grid, ids, segments, memory)
    %}

    let (direction) = move(grid_len, grid, 1)
    assert direction = Vector2(-1, 0)

    return ()
end

@external
func test_move_towards_single_dust_on_the_right{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local grid : Cell*
    local grid_len : felt

    const SHIP_ID = 1

    %{
        import sys, os
        sys.path.append(os.path.join(os.getcwd(), 'tests'))

        from helpers import empty_grid, store_grid, dust_cell, ship_cell
        grid = empty_grid(10)
        grid[3][7] = dust_cell()
        grid[3][5] = ship_cell(ids.SHIP_ID)
        store_grid(grid, ids, segments, memory)
    %}

    let (direction) = move(grid_len, grid, 1)
    assert direction = Vector2(1, 0)

    return ()
end

@external
func test_move_towards_single_dust_on_top_left{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local grid : Cell*
    local grid_len : felt

    const SHIP_ID = 1

    %{
        import sys, os
        sys.path.append(os.path.join(os.getcwd(), 'tests'))

        from helpers import empty_grid, store_grid, dust_cell, ship_cell
        grid = empty_grid(10)
        grid[0][0] = dust_cell()
        grid[3][5] = ship_cell(ids.SHIP_ID)
        store_grid(grid, ids, segments, memory)
    %}

    let (direction) = move(grid_len, grid, 1)
    assert direction = Vector2(-1, -1)

    return ()
end

@external
func test_move_towards_single_dust_on_top_right{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local grid : Cell*
    local grid_len : felt

    const SHIP_ID = 1

    %{
        import sys, os
        sys.path.append(os.path.join(os.getcwd(), 'tests'))

        from helpers import empty_grid, store_grid, dust_cell, ship_cell
        grid = empty_grid(10)
        grid[0][7] = dust_cell()
        grid[3][5] = ship_cell(ids.SHIP_ID)
        store_grid(grid, ids, segments, memory)
    %}

    let (direction) = move(grid_len, grid, 1)
    assert direction = Vector2(1, -1)

    return ()
end

@external
func test_move_towards_single_dust_on_bottom_left{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local grid : Cell*
    local grid_len : felt

    const SHIP_ID = 1

    %{
        import sys, os
        sys.path.append(os.path.join(os.getcwd(), 'tests'))

        from helpers import empty_grid, store_grid, dust_cell, ship_cell
        grid = empty_grid(10)
        grid[7][0] = dust_cell()
        grid[3][5] = ship_cell(ids.SHIP_ID)
        store_grid(grid, ids, segments, memory)
    %}

    let (direction) = move(grid_len, grid, 1)
    assert direction = Vector2(-1, 1)

    return ()
end

@external
func test_move_towards_single_dust_on_bottom_right{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local grid : Cell*
    local grid_len : felt

    const SHIP_ID = 1

    %{
        import sys, os
        sys.path.append(os.path.join(os.getcwd(), 'tests'))

        from helpers import empty_grid, store_grid, dust_cell, ship_cell
        grid = empty_grid(10)
        grid[7][9] = dust_cell()
        grid[3][5] = ship_cell(ids.SHIP_ID)
        store_grid(grid, ids, segments, memory)
    %}

    let (direction) = move(grid_len, grid, 1)
    assert direction = Vector2(1, 1)

    return ()
end

@external
func test_move_towards_nearest_dust{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local grid : Cell*
    local grid_len : felt

    const SHIP_ID = 1

    %{
        import sys, os
        sys.path.append(os.path.join(os.getcwd(), 'tests'))

        from helpers import empty_grid, store_grid, dust_cell, ship_cell
        grid = empty_grid(10) 
        grid[0][1] = dust_cell()
        grid[2][2] = dust_cell()
        grid[4][3] = dust_cell()
        grid[3][9] = dust_cell()
        grid[5][5] = dust_cell()

        grid[1][7] = ship_cell(ids.SHIP_ID)

        store_grid(grid, ids, segments, memory)
    %}

    let (direction) = move(grid_len, grid, 1)
    assert direction = Vector2(1, 1)

    return ()
end
