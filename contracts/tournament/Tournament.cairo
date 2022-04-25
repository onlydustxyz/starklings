# SPDX-License-Identifier: Apache-2.0
# OpenZeppelin Contracts for Cairo v0.1.0 (tournament/Tournament.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import (TRUE, FALSE)
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_contract_address

# OpenZeppeling dependencies
from openzeppelin.access.ownable import (Ownable_initializer, Ownable_only_owner)
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

# ------------
# STORAGE VARS
# ------------

@storage_var
func tournament_id_() -> (res : felt):
end

@storage_var
func tournament_name_() -> (res : felt):
end

@storage_var
func reward_token_address_() -> (res : felt):
end

@storage_var
func is_tournament_open_() -> (res : felt):
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
) -> (tournament_id : felt):
    let (reward_token_address) = reward_token_address_.read()
    return (reward_token_address)
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
        reward_token_address: felt
    ):
    Ownable_initializer(owner)
    tournament_id_.write(tournament_id)
    tournament_name_.write(tournament_name)
    reward_token_address_.write(reward_token_address)
    return ()
end

# -----
# EXTERNAL FUNCTIONS
# -----

@external
func open_tournament{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (success: felt):
    Ownable_only_owner()
    _only_tournament_closed()
    return (TRUE)
end

@external
func close_tournament{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (success: felt):
    Ownable_only_owner()
    _only_tournament_open()
    return (TRUE)
end

# -----
# INTERNAL FUNCTIONS
# -----

func _only_tournament_open{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
):
    let (is_tournament_open) = is_tournament_open_.read()
    with_attr error_message("Tournament: tournament is open"):
        is_tournament_open = TRUE
    end
    return ()
end

func _only_tournament_closed{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
):
    let (is_tournament_open) = is_tournament_open_.read()
    with_attr error_message("Tournament: tournament is closed"):
        is_tournament_open = FALSE
    end
    return ()
end