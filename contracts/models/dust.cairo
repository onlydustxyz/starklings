%lang starknet

struct Vector2:
    member x : felt
    member y : felt
end

struct Dust:
    member space_size : felt
    member position : Vector2
    member direction : Vector2
end
