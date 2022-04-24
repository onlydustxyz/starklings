%lang starknet

from starkware.cairo.common.uint256 import Uint256

struct Vector2:
    member x : felt
    member y : felt
end

struct Dust:
    member space_size : felt
    member position : Vector2
    member direction : Vector2
end

struct Cell:
    member dust_id : Uint256
    member ship : felt
end
