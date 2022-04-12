from starkware.cairo.common.uint256 import Uint256

struct Vector2:
    member x : felt
    member y : felt
end

struct Dust:
    member token_id : Uint256
    member position : Vector2
    member direction : Vector2
end
