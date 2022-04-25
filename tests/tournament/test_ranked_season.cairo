%lang starknet

from contracts.interfaces.iranked_season import IRankedSeason
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address

const ONLY_DUST_TOKEN_ADDRESS = 0x3fe90a1958bb8468fb1b62970747d8a00c435ef96cda708ae8de3d07f1bb56b


@external
func test_ranked_season{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    tempvar only_dust_token_address = ONLY_DUST_TOKEN_ADDRESS
    local ranked_season_address : felt
    %{ 
        ids.ranked_season_address = deploy_contract(
            "./contracts/tournament/RankedSeason.cairo", 
            [1, 2, 3, ids.only_dust_token_address]
        ).contract_address 
    %}
    %{ mock_call(ids.only_dust_token_address, "balanceOf", [100, 0]) %}
    let (reward_total_amount) = IRankedSeason.reward_total_amount(ranked_season_address)
    assert reward_total_amount.low = 100
    assert reward_total_amount.high = 0

    %{ stop_expecting_revert = expect_revert(error_message="Ownable: caller is not the owner") %}
    IRankedSeason.open_season(ranked_season_address)
    %{ stop_expecting_revert() %}   

    # Changes caller address to owner
    %{ start_prank(1) %}
    IRankedSeason.open_season(ranked_season_address)
    let (is_open) = IRankedSeason.is_season_open(ranked_season_address)
    assert is_open = FALSE
    %{ stop_prank() %}
    return ()
end
