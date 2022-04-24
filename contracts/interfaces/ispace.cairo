%lang starknet

from contracts.models.common import Cell

@contract_interface
namespace ISpace:
    func initialize(dust_contract_address, size, turn_count, max_dust) -> ():
    end

    func add_ship(x, y, ship_contract):
    end

    func next_turn() -> ():
    end

    func get_grid_state() -> (grid_state_len : felt, grid_state : Cell*):
    end
end
