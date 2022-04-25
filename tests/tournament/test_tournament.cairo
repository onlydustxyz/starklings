%lang starknet

from contracts.interfaces.itournament import ITournament
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address

const ONLY_DUST_TOKEN_ADDRESS = 0x3fe90a1958bb8468fb1b62970747d8a00c435ef96cda708ae8de3d07f1bb56b
const BOARDING_TOKEN_ADDRESS = 0x00348f5537be66815eb7de63295fcb5d8b8b2ffe09bb712af4966db7cbb04a95
const RAND_ADDRESS = 0x00348f5537be66815eb7de63295fcb5d8b8b2ffe09bb712af4966db7cbb04a91
const SPACE_ADDRESS = 0x00348f5537be66815eb7de63295fcb5d8b8b2ffe09bb712af4966db7cbb04aaa

@external
func test_tournament{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    tempvar only_dust_token_address = ONLY_DUST_TOKEN_ADDRESS
    tempvar boarding_pass_token_address = BOARDING_TOKEN_ADDRESS
    tempvar rand_address = RAND_ADDRESS
    tempvar space_address = SPACE_ADDRESS

    local tournament_address : felt
    %{ 
        ids.tournament_address = deploy_contract(
            "./contracts/tournament/Tournament.cairo", 
            [
                42, # Owner
                2, # Tournament Id
                3, # Tournament Name
                ids.only_dust_token_address, # ERC20 token address of the reward
                ids.boarding_pass_token_address, # ERC721 token address for access control
                ids.rand_address, # Random generator contract address
                ids.space_address, # Space contract address
                2, # Ships per battle
                8, # Maximum Ships per tournament
                5, # grid_size
                3, # turn_count
                2, # max_dust
            ]
        ).contract_address 
    %}
    %{ mock_call(ids.only_dust_token_address, "balanceOf", [100, 0]) %}
    let (reward_total_amount) = ITournament.reward_total_amount(tournament_address)
    assert reward_total_amount.low = 100
    assert reward_total_amount.high = 0  

    # Start registration
    %{ start_prank(42) %}
    let (is_open) = ITournament.are_tournament_registrations_open(tournament_address)
    assert is_open = FALSE

    ITournament.open_tournament_registrations(tournament_address)

    let (is_open) = ITournament.are_tournament_registrations_open(tournament_address)
    assert is_open = TRUE
    %{ stop_prank() %}


    # Player 1 registers ship 1
    %{ start_prank(1) %}
    ITournament.register(tournament_address, 1)
    %{ stop_prank() %}

    # Player 2 registers ship 2
    %{ start_prank(2) %}
    ITournament.register(tournament_address, 2)
    %{ stop_prank() %}

    # Player 3 registers ship 3
    %{ start_prank(3) %}
    ITournament.register(tournament_address, 3)
    %{ stop_prank() %}

    # Close registration
    %{ start_prank(42) %}
    ITournament.close_tournament_registrations(tournament_address)
    let (is_open) = ITournament.are_tournament_registrations_open(tournament_address)
    assert is_open = FALSE
    %{ stop_prank() %}

    let (played_battle_count) = ITournament.played_battle_count(tournament_address)
    assert played_battle_count = 0

    # Play the entire game
    %{ start_prank(42) %}
    ITournament.start(tournament_address)
    %{ stop_prank() %}

    let (played_battle_count) = ITournament.played_battle_count(tournament_address)
    assert played_battle_count = 2

    return ()
end
