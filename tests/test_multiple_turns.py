import pytest

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract
from starkware.starknet.public.abi import get_selector_from_name

from fixtures import *
from deploy import deploy_contract

ADMIN = get_selector_from_name("admin")
SPACE_SIZE = 5
MAX_TURN = 10
MAX_DUST = 100
MAX_FELT = 2**251 + 17 * 2**192 + 1


@pytest.fixture
async def space_factory(starknet: Starknet) -> StarknetContract:
    space = await deploy_contract(starknet, "core/space.cairo")
    return space


@pytest.mark.asyncio
async def test_multiple_turns(starknet: Starknet, space_factory):
    space = space_factory

    rand = await deploy_contract(starknet, "core/rand.cairo")
    ship = await deploy_contract(starknet, "ships/basic_ship.cairo")

    await space.play_game(
        rand.contract_address,
        SPACE_SIZE,
        MAX_TURN,
        MAX_DUST,
        [(ship.contract_address, (1, 3)), (ship.contract_address, (5, 3))],
    ).invoke(caller_address=ADMIN)
