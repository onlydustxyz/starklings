%lang starknet

@contract_interface
namespace IRandom:
    func generate_random_numbers(salt : felt) -> (r1, r2, r3, r4, r5):
    end
end
