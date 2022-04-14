%lang starknet

from contracts.models.common import Vector2

@contract_interface
namespace IShip:
    func move() -> (new_direction : Vector2):
    end
end
