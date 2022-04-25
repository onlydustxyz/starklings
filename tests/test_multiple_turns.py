from typing import List, NamedTuple
import pytest

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract
from starkware.starknet.public.abi import get_selector_from_name

from fixtures import *
from deploy import deploy_contract

ADMIN = get_selector_from_name('admin')
SPACE_SIZE = 5
MAX_TURN = 200
MAX_DUST = 20
MAX_FELT = 2**251 + 17 * 2**192 + 1

@pytest.fixture
async def space_factory(starknet: Starknet) -> StarknetContract:
    rand = await deploy_contract(starknet, 'test/fake_rand.cairo')
    space = await deploy_contract(starknet, 'core/space.cairo')
    dust = await deploy_contract(starknet, 'core/dust.cairo', constructor_calldata=[space.contract_address, rand.contract_address])
    ship = await deploy_contract(starknet, 'ships/random_move_ship.cairo', constructor_calldata=[rand.contract_address])
    await space.initialize(dust.contract_address, SPACE_SIZE, MAX_TURN, MAX_DUST).invoke(caller_address=ADMIN)
    await space.add_ship(3, 3, ship.contract_address).invoke(caller_address=ADMIN)
    await space.add_ship(1, 3, ship.contract_address).invoke(caller_address=ADMIN)
    return space, dust


@pytest.mark.asyncio
async def test_multiple_turns(space_factory):
    (space, _) = space_factory

    for _ in range(MAX_TURN):
        await space.next_turn().invoke(caller_address=ADMIN)
