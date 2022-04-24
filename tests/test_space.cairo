%lang starknet

from contracts.interfaces.ispace import ISpace
from contracts.models.common import Cell, Vector2
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from protostar.asserts import assert_eq

@external
func test_ship{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local space_address : felt
    local rand_address : felt
    local dust_address : felt
    local random_move_ship_address : felt

    # We deploy contract and put its address into a local variable. Second argument is calldata array
    %{ ids.space_address = deploy_contract("./contracts/core/space.cairo", []).contract_address %}
    %{ ids.rand_address = deploy_contract("./contracts/test/fake_rand.cairo", []).contract_address %}
    %{ ids.dust_address = deploy_contract("./contracts/core/dust.cairo", [ids.space_address, ids.rand_address]).contract_address %}
    %{ ids.random_move_ship_address = deploy_contract("./contracts/ships/random_move_ship.cairo", [ids.rand_address]).contract_address %}

    ISpace.initialize(
        contract_address=space_address,
        dust_contract_address=dust_address,
        size=5,
        turn_count=10,
        max_dust=10)
    ISpace.add_ship(
        contract_address=space_address, x=3, y=1, ship_contract=random_move_ship_address)

    let (grid_state_len, grid_state) = ISpace.get_grid_state(contract_address=space_address)
    assert grid_state_len = 25  # 5*5

    let ship_cell : Cell = grid_state[8]  # x=3, y=1
    assert_eq(ship_cell.dust_id.low, 0)
    assert_eq(ship_cell.ship, random_move_ship_address)

    ISpace.next_turn(contract_address=space_address)

    let dust_cell : Cell = grid_state[5]  # x=0, y=1
    assert_eq(dust_cell.position.x, 0)
    assert_eq(dust_cell.position.y, 1)
    assert_eq(dust_cell.dust_id.low, 0)
    assert_eq(dust_cell.ship, 0)

    return ()
end
