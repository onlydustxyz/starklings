%lang starknet

from contracts.models.common import Vector2

@contract_interface
namespace IShip:
    func move() -> (new_direction : Vector2):
    end

    # ERC165
    func supportsInterface(interfaceId : felt) -> (success : felt):
    end
end
