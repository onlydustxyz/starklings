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
