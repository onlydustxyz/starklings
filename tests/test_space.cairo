%lang starknet

from contracts.interfaces.ispace import ISpace
from contracts.models.common import Cell, Vector2
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address


@contract_interface
namespace StorageContract:
    func get_grid_state() -> (grid_state_len: felt, grid_state: Cell*):
    end
end

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
        contract_address=space_address, x=1, y=1, ship_contract=random_move_ship_address)

    let (grid_state_len, grid_state) = StorageContract.get_grid_state(contract_address=space_address)
    assert grid_state[6] = Cell(position=Vector2(1, 1), dust_id=Uint256(0, 0), ship=random_move_ship_address)
    ISpace.next_turn(contract_address=space_address)
    
    ISpace.next_turn(contract_address=space_address)

    return ()
end
