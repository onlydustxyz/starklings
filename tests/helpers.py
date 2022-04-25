from utils import to_uint

def dust_cell(dust_id): return [to_uint(dust_id), 0]
def ship_cell(ship_id): return [to_uint(0), ship_id]
def empty_cell(): return [to_uint(0), 0]

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
        memory[grid_ptr + 3*i] = dust[0]
        memory[grid_ptr + 3*i + 1] = dust[1]
        memory[grid_ptr + 3*i + 2] = ship

def display(cell):
    dust, ship = cell
    return '*' if dust[0] > 0 else str(ship) if ship > 0 else ' '

def print_grid(grid):
    grid_len = len(grid)
    print()
    print('+' + '-'*grid_len + '+')
    for row in grid:
        disp_row = [display(cell) for cell in row]
        print('|' + ''.join(disp_row) + '|')
    print('+' + '-'*grid_len + '+')

    