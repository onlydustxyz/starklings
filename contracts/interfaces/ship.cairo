%lang starknet

from contracts.models.dust import Vector2

@contract_interface
namespace IShip:
    func move() -> (new_position : Vector2):
    end
end
