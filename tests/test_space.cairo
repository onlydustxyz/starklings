%lang starknet

from contracts.interfaces.ispace import ISpace
from contracts.models.common import Cell, Vector2, ShipInit
from contracts.core.space import play_game
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin, BitwiseBuiltin

@external
func test_game{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr}():
    alloc_locals

    local space_address : felt
    local rand_address : felt

    local random_move_ship_address : felt
    let fp_and_pc = get_fp_and_pc()
    local __fp__ = fp_and_pc.fp_val  # A.

    # We deploy contract and put its address into a local variable. Second argument is calldata array
    %{ ids.rand_address = deploy_contract("./contracts/test/fake_rand.cairo", []).contract_address %}
    %{ ids.random_move_ship_address = deploy_contract("./contracts/ships/random_move_ship.cairo", [ids.rand_address]).contract_address %}

    local ship : ShipInit

    assert ship.position.x = 3
    assert ship.position.y = 1
    assert ship.address = random_move_ship_address

    play_game(
        rand_contract_address=rand_address,
        size=5,
        turn_count=10,
        max_dust=10,
        ships_len=1,
        ships=&ship)

    return ()
end
