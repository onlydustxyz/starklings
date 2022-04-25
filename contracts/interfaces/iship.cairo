%lang starknet

from contracts.models.common import Vector2

@contract_interface
namespace IShip:
    func move(grid_state_len: felt, grid_state: felt*, ship_id: felt) -> (new_direction : Vector2):
    end

    # ERC165
    func supportsInterface(interfaceId : felt) -> (success : felt):
    end
end
