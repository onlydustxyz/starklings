import pytest

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract
from starkware.starknet.public.abi import get_selector_from_name

from fixtures import *
from deploy import deploy_contract
from utils import assert_revert, str_to_felt, to_uint

DUST_CONTRACT = get_selector_from_name('Dust')

@pytest.fixture
async def space(starknet: Starknet) -> StarknetContract:
    execution_info = await deploy_contract(starknet, 'test/dummy_dust.cairo')
    return await deploy_contract(starknet, 'core/space.cairo', constructor_calldata=[execution_info.contract_address, 10])


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
async def test_next_turn(space):
    execution_info = await space.get_dust_at(3, 7).call()
    assert execution_info.result == (to_uint(0),)
    execution_info = await space.next_turn().invoke()
    execution_info = await space.get_dust_at(3, 7).call()
    assert execution_info.result == (to_uint(42),)

