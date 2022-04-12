# Declare this file as a StarkNet contract.
%lang starknet

from contracts.models.dust import Vector2, Dust
from starkware.cairo.common.uint256 import Uint256

@external
func move(dust_id : Uint256) -> (new_position : Vector2):
    let pos = Vector2(3, 7)
    return (pos)
end

@external
func burn(dust_id : Uint256):
    return ()
end
