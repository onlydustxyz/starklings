%lang starknet

from contracts.interfaces.ispace import ISpace
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address

@external
func test_ship{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local space_address : felt
    local rand_address : felt
    local dust_address : felt
    local random_move_ship_address : felt

    # We deploy contract and put its address into a local variable. Second argument is calldata array
    %{ ids.space_address = deploy_contract("./contracts/core/space.cairo", []).contract_address %}
    %{ ids.rand_address = deploy_contract("./contracts/core/rand.cairo", []).contract_address %}
    %{ ids.dust_address = deploy_contract("./contracts/core/dust.cairo", [ids.space_address, ids.rand_address]).contract_address %}
    %{ ids.random_move_ship_address = deploy_contract("./contracts/ships/random_move_ship.cairo", [ids.rand_address]).contract_address %}

    ISpace.initialize(
        contract_address=space_address,
        dust_contract_address=dust_address,
        size=5,
        turn_count=10,
        max_dust=10)
    ISpace.add_ship(
        contract_address=space_address, x=0, y=0, ship_contract=random_move_ship_address)

    ISpace.next_turn(contract_address=space_address)
    ISpace.next_turn(contract_address=space_address)

    return ()
end
