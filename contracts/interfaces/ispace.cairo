%lang starknet

from contracts.models.common import ShipInit

@contract_interface
namespace ISpace:
    func play_game(
            rand_contract_address : felt, size : felt, turn_count : felt, max_dust : felt,
            ships_len : felt, ships : ShipInit*) -> ():
    end
end
