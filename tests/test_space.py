import pytest

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract
from starkware.starknet.public.abi import get_selector_from_name

from fixtures import *
from deploy import deploy_contract
from utils import assert_revert, str_to_felt, to_uint


@pytest.fixture
async def space_factory(starknet: Starknet) -> StarknetContract:
    space = await deploy_contract(starknet, 'core/space.cairo')
    dust = await deploy_contract(starknet, 'core/dust.cairo', constructor_calldata=[space.contract_address])
    await space.init(dust.contract_address, 20).invoke()
    return space, dust

class Signers:
    pass


@pytest.fixture
def signers() -> Signers:
    signers = Signers()
    signers.admin = get_selector_from_name('admin')
    signers.anyone = get_selector_from_name('anyone')
    return signers


#
# Constructor
#


@pytest.mark.asyncio
async def test_next_turn(space_factory):
    space, dust = space_factory

    execution_info = await space.get_dust_at(1, 1).call()
    assert execution_info.result == (to_uint(0),)
    execution_info = await space.get_dust_at(2, 1).call()
    assert execution_info.result == (to_uint(0),)

    execution_info = await space.next_turn().invoke()

    execution_info = await space.get_dust_at(1, 1).call()
    assert execution_info.result == (to_uint(0),)
    execution_info = await space.get_dust_at(2, 1).call()
    assert execution_info.result == (to_uint(1),)

    execution_info = await space.next_turn().invoke()

    execution_info = await space.get_dust_at(1, 1).call()
    assert execution_info.result == (to_uint(0),)
    execution_info = await space.get_dust_at(2, 1).call()
    # a collision occured between dust 2 and dust 1. Dust 2 is burnt.
    assert execution_info.result == (to_uint(0),)
    execution_info = await space.get_dust_at(3, 1).call()
    assert execution_info.result == (to_uint(1),)

    execution_info = await space.next_turn().invoke()

    execution_info = await space.get_dust_at(1, 1).call()
    assert execution_info.result == (to_uint(0),)
    execution_info = await space.get_dust_at(2, 1).call()
    assert execution_info.result == (to_uint(3),)
    execution_info = await space.get_dust_at(3, 1).call()
    assert execution_info.result == (to_uint(0),)
    execution_info = await space.get_dust_at(4, 1).call()
    assert execution_info.result == (to_uint(1),)

