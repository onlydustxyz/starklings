%lang starknet

from contracts.interfaces.ispace import ISpace
from starkware.starknet.common.syscalls import get_contract_address

@external
func test_proxy_contract{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local space_address : felt
    local rand_address : felt
    local dust_address : felt
    let (admin) = get_contract_address()

    # We deploy contract and put its address into a local variable. Second argument is calldata array
    %{ ids.space_address = deploy_contract("./contracts/core/space.cairo", []).contract_address %}
    %{ ids.rand_address = deploy_contract("./contracts/core/rand.cairo", []).contract_address %}
    %{ ids.dust_address = deploy_contract("./contracts/core/dust.cairo", [ids.admin, ids.rand_address]).contract_address %}
    ISpace.initialize(contract_address=space_address, dust_contract_address=dust_address, size=5)
    return ()
end
