# SPDX-License-Identifier: Apache-2.0
# OpenZeppelin Contracts for Cairo v0.1.0 (tournament/RankedSeason.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_contract_address

# OpenZeppeling dependencies
from openzeppelin.access.ownable import (Ownable_initializer, Ownable_only_owner)
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

# ------------
# STORAGE VARS
# ------------

@storage_var
func season_id_() -> (res : felt):
end

@storage_var
func season_name_() -> (res : felt):
end

@storage_var
func reward_token_address_() -> (res : felt):
end

# -----
# VIEWS
# -----
@view
func season_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (season_id : felt):
    let (season_id) = season_id_.read()
    return (season_id)
end

@view
func season_name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (season_name : felt):
    let (season_name) = season_name_.read()
    return (season_name)
end

@view
func reward_token_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (season_id : felt):
    let (reward_token_address) = reward_token_address_.read()
    return (reward_token_address)
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

@constructor
func constructor{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        owner: felt,
        season_id: felt,
        season_name: felt,
        reward_token_address: felt
    ):
    Ownable_initializer(owner)
    season_id_.write(season_id)
    season_name_.write(season_name)
    reward_token_address_.write(reward_token_address)
    return ()
end