%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace ITournament:

    func start() -> ():
    end

    func open_tournament_registrations() -> ():
    end

    func close_tournament_registrations() -> ():
    end

    func register(ship_address) -> ():
    end

    func tournament_id() -> (res: felt):
    end

    func tournament_name() -> (res: felt):
    end

    func reward_token_address() -> (res: felt):
    end

    func boarding_pass_token_address() -> (res: felt):
    end

    func rand_contract_address() -> (res: felt):
    end

    func reward_total_amount() -> (res: Uint256):
    end

    func are_tournament_registrations_open() -> (res: felt):
    end

    func ships_per_battle() -> (res: felt):
    end

    func max_ships_per_tournament() -> (res: felt):
    end

    func grid_size() -> (res : felt):
    end

    func turn_count() -> (res : felt):
    end

    func max_dust() -> (res : felt):
    end

    func player_count() -> (res: felt):
    end

    func player_ship(player_address: felt) -> (res: felt):
    end

    func ship_player(ship_address: felt) -> (res: felt):
    end
    
    func played_battle_count() -> (res : felt):
    end
end
