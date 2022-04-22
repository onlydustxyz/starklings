%lang starknet

@contract_interface
namespace ISpace:
    func initialize(dust_contract_address, size, turn_count, max_dust) -> ():
    end

    func add_ship(x, y, ship_contract):
    end

    func next_turn() -> ():
    end
end
