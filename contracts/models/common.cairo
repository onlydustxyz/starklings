%lang starknet

struct Vector2:
    member x : felt
    member y : felt
end

struct Dust:
    member present : felt
    member direction : Vector2
end

struct Cell:
    member dust : Dust
    member ship_id : felt
end

struct Context:
    member grid_size : felt
    member grid : Cell*
    member next_grid : Cell*
    member max_turn_count : felt
    member max_dust : felt
    member rand_contract : felt
    member ships_len : felt
    member ships : felt*
end

struct ShipInit:
    member address : felt
    member position : Vector2
end
