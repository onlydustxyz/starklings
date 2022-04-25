%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace ITournament:

    func open_tournament() -> ():
    end

    func close_tournament() -> ():
    end

    func tournament_id() -> (res: felt):
    end

    func tournament_name() -> (res: felt):
    end

    func reward_token_address() -> (res: felt):
    end

    func reward_total_amount() -> (res: Uint256):
    end

    func is_tournament_open() -> (res: felt):
    end
end
