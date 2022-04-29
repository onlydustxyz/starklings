from typing import List, NamedTuple
import pytest

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract
from starkware.starknet.public.abi import get_selector_from_name

from fixtures import *
from deploy import deploy_contract
from utils import assert_revert, to_uint

ADMIN = get_selector_from_name("admin")
ANYONE = get_selector_from_name("anyone")
SPACE_SIZE = 6
MAX_TURN = 50
MAX_DUST = 2
MAX_FELT = 2**251 + 17 * 2**192 + 1

SHIP1 = 100
SHIP2 = 102
SHIP3 = 103
SHIP4 = 104
PLAYER1 = get_selector_from_name("player1")
PLAYER2 = get_selector_from_name("player2")
PLAYER3 = get_selector_from_name("player3")
PLAYER4 = get_selector_from_name("player4")

# Auxiliary functions
def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")


def uint(a):
    return (a, 0)


@pytest.fixture
async def tournament_factory(starknet: Starknet) -> StarknetContract:

    name = str_to_felt("OnlyDust")
    symbol = str_to_felt("ODUST")
    decimals = 18
    recipient = ADMIN
    onlyDust = await deploy_contract(
        starknet,
        "token/OnlyDust.cairo",
        constructor_calldata=[name, symbol, decimals, 1000000, 0, recipient],
    )

    name = str_to_felt("StarKonquestBoardingPass")
    symbol = str_to_felt("SKBP")
    owner = ADMIN
    starKonquestBoardingPass = await deploy_contract(
        starknet,
        "token/StarKonquestBoardingPass.cairo",
        constructor_calldata=[name, symbol, owner],
    )
    await starKonquestBoardingPass.mint(PLAYER1, (1, 0)).invoke(caller_address=ADMIN)
    await starKonquestBoardingPass.mint(PLAYER2, (2, 0)).invoke(caller_address=ADMIN)
    await starKonquestBoardingPass.mint(PLAYER3, (3, 0)).invoke(caller_address=ADMIN)
    await starKonquestBoardingPass.mint(PLAYER4, (4, 0)).invoke(caller_address=ADMIN)

    space = await deploy_contract(starknet, "core/space.cairo")
    rand = await deploy_contract(starknet, "core/rand.cairo")
    space = await deploy_contract(starknet, "test/fake_space.cairo")

    owner = ADMIN
    season_id = 1
    season_name = str_to_felt("StarkNet Hackathon AMS")
    reward_token_address = onlyDust.contract_address
    boarding_pass_token_address = starKonquestBoardingPass.contract_address
    ships_per_battle = 2
    max_players = 16
    params = [
        owner,
        season_id,
        season_name,
        reward_token_address,
        boarding_pass_token_address,
        rand.contract_address,
        space.contract_address,
        ships_per_battle,
        max_players,
        6,
        3,
        2,
    ]
    tournament = await deploy_contract(
        starknet, "tournament/Tournament.cairo", constructor_calldata=params
    )

    return tournament


@pytest.mark.asyncio
async def test_tournament_e2e(tournament_factory):
    tournament = tournament_factory

    execution_info = await tournament.are_tournament_registrations_open().call()
    assert execution_info.result == (0,)

    await tournament.open_tournament_registrations().invoke(caller_address=ADMIN)

    execution_info = await tournament.are_tournament_registrations_open().call()
    assert execution_info.result == (1,)

    await tournament.register(SHIP1).invoke(caller_address=PLAYER1)
    await tournament.register(SHIP2).invoke(caller_address=PLAYER2)
    await tournament.register(SHIP3).invoke(caller_address=PLAYER3)
    await tournament.register(SHIP4).invoke(caller_address=PLAYER4)

    await tournament.close_tournament_registrations().invoke(caller_address=ADMIN)

    execution_info = await tournament.are_tournament_registrations_open().call()
    assert execution_info.result == (0,)

    await tournament.start().invoke(caller_address=ADMIN)

    execution_info = await tournament.played_battle_count().call()
    assert execution_info.result == (3,)  # 2 battles in first round, and 1 final battle
