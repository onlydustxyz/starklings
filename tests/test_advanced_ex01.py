from importlib_metadata import metadata
import pytest
import logging

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract
from starkware.starknet.public.abi import get_selector_from_name

from fixtures import *
from deploy import deploy_contract

SPACE_CONTRACT = get_selector_from_name('Space')


@pytest.fixture
async def rand_factory(starknet: Starknet) -> StarknetContract:
    rand = await deploy_contract(starknet, 'ex/advanced/ex01.cairo')
    account1 = await deploy_contract(starknet, 'openzeppelin/token/erc721/utils/ERC721_Holder.cairo')
    account2 = await deploy_contract(starknet, 'openzeppelin/token/erc721/utils/ERC721_Holder.cairo')

    return rand, account1, account2

value_first_block = 0


@pytest.mark.asyncio
async def test_rand(rand_factory):
    rand, _, _ = rand_factory

    # Diff seeds
    rand1 = await rand.generate_random_numbers(42).invoke()
    rand2 = await rand.generate_random_numbers(21).invoke()
    assert rand1.result != rand2.result


@pytest.mark.asyncio
async def test_rand(rand_factory):
    rand, _, _ = rand_factory
