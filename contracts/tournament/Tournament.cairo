# SPDX-License-Identifier: Apache-2.0
# StarKonquest smart contracts written in Cairo v0.1.0 (tournament/Tournament.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import (TRUE, FALSE)
from starkware.cairo.common.math import (assert_lt, assert_nn)
from starkware.cairo.common.uint256 import (Uint256, uint256_le)
from starkware.starknet.common.syscalls import (get_contract_address, get_caller_address)

# OpenZeppeling dependencies
from openzeppelin.access.ownable import (Ownable_initializer, Ownable_only_owner)
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from openzeppelin.token.erc721.interfaces.IERC721 import IERC721

from contracts.interfaces.ispace import ISpace


# ------------
# STORAGE VARS
# ------------

# Id of the tournament
@storage_var
func tournament_id_() -> (res : felt):
end

# Name of the tournament
@storage_var
func tournament_name_() -> (res : felt):
end

# ERC20 token address for the reward
@storage_var
func reward_token_address_() -> (res : felt):
end

# ERC721 token address for access control
@storage_var
func boarding_pass_token_address_() -> (res : felt):
end

# Random generator contract address
@storage_var
func rand_contract_address_() -> (res : felt):
end

# Whether or not registration are open
@storage_var
func is_tournament_open_() -> (res : felt):
end

# Number of ships per battle
@storage_var
func ships_per_battle_() -> (res : felt):
end

# Number of ships per tournament
@storage_var
func max_ships_per_tournament_() -> (res : felt):
end

# Number of players
@storage_var
func player_count_() -> (res : felt):
end

# Player registered ship
@storage_var
func player_ship_(player_address: felt) -> (res : felt):
end

# Ship associated player
@storage_var
func ship_player_(ship_address: felt) -> (res : felt):
end

# Player scores
@storage_var
func player_score_(player_address: felt) -> (res : felt):
end

# -----
# VIEWS
# -----
@view
func tournament_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (tournament_id : felt):
    let (tournament_id) = tournament_id_.read()
    return (tournament_id)
end

@view
func tournament_name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (tournament_name : felt):
    let (tournament_name) = tournament_name_.read()
    return (tournament_name)
end

@view
func reward_token_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (reward_token_address : felt):
    let (reward_token_address) = reward_token_address_.read()
    return (reward_token_address)
end

@view
func boarding_pass_token_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (boarding_pass_token_address : felt):
    let (boarding_pass_token_address) = boarding_pass_token_address_.read()
    return (boarding_pass_token_address)
end

@view
func rand_contract_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (rand_contract_address : felt):
    let (rand_contract_address) = rand_contract_address_.read()
    return (rand_contract_address)
end

@view
func is_tournament_open{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (is_tournament_open : felt):
    let (is_tournament_open) = is_tournament_open_.read()
    return (is_tournament_open)
end

@view
func reward_total_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (reward_total_amount : Uint256):
    let (reward_token_address) = reward_token_address_.read()
    let (contract_address) = get_contract_address()
    let (reward_total_amount) = IERC20.balanceOf(
        contract_address=reward_token_address, account=contract_address
    )
    return (reward_total_amount)
end

@view
func ships_per_battle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (ships_per_battle : felt):
    let (ships_per_battle) = ships_per_battle_.read()
    return (ships_per_battle)
end

@view
func max_ships_per_tournament{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (max_ships_per_tournament : felt):
    let (max_ships_per_tournament) = max_ships_per_tournament_.read()
    return (max_ships_per_tournament)
end

@view
func player_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (player_count : felt):
    let (player_count) = player_count_.read()
    return (player_count)
end

@view
func player_ship{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    player_adress: felt
) -> (player_ship : felt):
    let (player_ship) = player_ship_.read(player_adress)
    return (player_ship)
end

@view
func ship_player{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ship_adress: felt
) -> (ship_player : felt):
    let (ship_player) = ship_player_.read(ship_adress)
    return (ship_player)
end

@view
func player_score{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    player_adress: felt
) -> (player_score : felt):
    let (player_score) = player_score_.read(player_adress)
    return (player_score)
end

# -----
# CONSTRUCTOR
# -----

@constructor
func constructor{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        owner: felt,
        tournament_id: felt,
        tournament_name: felt,
        reward_token_address: felt,
        boarding_pass_token_address: felt,
        rand_contract_address: felt,
        ships_per_battle: felt,
        max_ships_per_tournament: felt
    ):
    Ownable_initializer(owner)
    tournament_id_.write(tournament_id)
    tournament_name_.write(tournament_name)
    reward_token_address_.write(reward_token_address)
    boarding_pass_token_address_.write(boarding_pass_token_address)
    rand_contract_address_.write(rand_contract_address)
    ships_per_battle_.write(ships_per_battle)
    max_ships_per_tournament_.write(max_ships_per_tournament)
    player_count_.write(0)
    return ()
end

# -----
# EXTERNAL FUNCTIONS
# -----

# Open tournament registration
@external
func open_tournament_registration{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (success: felt):
    Ownable_only_owner()
    _only_tournament_closed()
    return (TRUE)
end

# Close tournament registration
@external
func close_tournament_registration{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (success: felt):
    Ownable_only_owner()
    _only_tournament_open()
    return (TRUE)
end


# Start the tournament
@external
func start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (success: felt):
    # TODO: implement start function
    return (TRUE)
end

# Register a ship for the caller address
# @param ship_address: the address of the ship smart contract
@external
func register{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ship_address: felt
) -> (success: felt):
    alloc_locals
    _only_tournament_open()
    let (player_address) = get_caller_address()
    let (boarding_pass_token_address) = boarding_pass_token_address_.read()
    # Check access control with NFT boarding pass
    let (player_boarding_pass_balance) = IERC721.balanceOf(
        contract_address=boarding_pass_token_address,
        owner=player_address
    )
    let one = Uint256(1, 0)
    let (is_allowed) = uint256_le(one, player_boarding_pass_balance)
    with_attr error_message("Tournament: player is not allowed to register"):
        assert is_allowed = TRUE
    end   
    let (current_player_count) = player_count_.read()
    let (max_ships_per_tournament) = max_ships_per_tournament_.read()
    # Check that we did not reach the max number of players
    with_attr error_message("Tournament: max player count reached"):
        assert_lt(current_player_count, max_ships_per_tournament)
    end
    let (player_registerd_ship) = player_ship_.read(player_address)
    # Check if player already registered a ship for this tournament
    with_attr error_message("Tournament: player already registered"):
        assert player_registerd_ship = 0
    end
    let (ship_registered_player) = ship_player_.read(ship_address)
    # Check if ship has not been registered by another player
    with_attr error_message("Tournament: ship already registered"):
        assert ship_registered_player = 0
    end
    # Write player => ship association
    player_ship_.write(player_address, ship_address)
    # Write ship => player association
    ship_player_.write(ship_address, player_address)
    return (TRUE)
end


# -----
# INTERNAL FUNCTIONS
# -----

func _increase_score{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    player_address: felt, points: felt
):
    let (current_score) = player_score_.read(player_address)
    tempvar new_score
    assert new_score = current_score + points
    player_score_.write(player_address, new_score)
    return ()
end

func _decrease_score{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    player_address: felt, points: felt
):
    let (current_score) = player_score_.read(player_address)
    tempvar new_score
    assert new_score = current_score - points
    player_score_.write(player_address, new_score)
    return ()
end

func _only_tournament_open{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
):
    let (is_tournament_open) = is_tournament_open_.read()
    with_attr error_message("Tournament: tournament is open"):
        assert is_tournament_open = TRUE
    end
    return ()
end

func _only_tournament_closed{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
):
    let (is_tournament_open) = is_tournament_open_.read()
    with_attr error_message("Tournament: tournament is closed"):
        assert is_tournament_open = FALSE
    end
    return ()
end