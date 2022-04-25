%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin, BitwiseBuiltin
from starkware.cairo.common.math import (assert_le)
from contracts.models.common import ShipInit

@external
func play_game{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        rand_contract_address : felt, size : felt, turn_count : felt, max_dust : felt,
        ships_len : felt, ships : ShipInit*) -> ():
    assert_le(ships_len, 2)
    assert_le(1, ships_len)
    return ()
end