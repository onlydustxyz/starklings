def dust_cell(): return [(1, (0,0)), 0]
def ship_cell(ship_id): return [(0, (0,0)), ship_id]
def empty_cell(): return [(0, (0,0)), 0]

def empty_grid(grid_size):
    return [[empty_cell() for _ in range(grid_size)] for _ in range(grid_size)]

def flatten(grid):
    return [cell for row in grid for cell in row] 

def store_grid(grid, ids, segments, memory):
    flat_grid = flatten(grid)
    ids.grid_len = len(flat_grid)
    ids.grid = grid_ptr = segments.add()
    for i in range(len(flat_grid)):
        dust, ship = flat_grid[i]
        present, direction = dust
        memory[grid_ptr + 4*i] = present
        memory[grid_ptr + 4*i + 1] = direction[0]
        memory[grid_ptr + 4*i + 2] = direction[1]
        memory[grid_ptr + 4*i + 3] = ship

def display(cell):
    dust, ship = cell
    return '*' if dust[0] == 1 else str(ship) if ship > 0 else ' '

def print_grid(grid):
    grid_len = len(grid)
    print()
    print('+' + '-'*grid_len + '+')
    for row in grid:
        disp_row = [display(cell) for cell in row]
        print('|' + ''.join(disp_row) + '|')
    print('+' + '-'*grid_len + '+')

    