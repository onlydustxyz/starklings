"""contract.cairo test file."""
import os

import pytest
from fixtures import *
from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract
from deploy import deploy_contract


# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "ex01.cairo")


@pytest.fixture
async def dust_factory(starknet: Starknet) -> StarknetContract:
    account1 = await deploy_contract(starknet, 'openzeppelin/token/erc721/utils/ERC721_Holder.cairo')
    account2 = await deploy_contract(starknet, 'openzeppelin/token/erc721/utils/ERC721_Holder.cairo')
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    return contract, account1, account2


@pytest.mark.asyncio
async def test_collect_dust(dust_factory):
    contract, a, _ = dust_factory

    await contract.collect_dust(10).invoke(caller_address=a.contract_address)

    owned_dust = await contract.view_dust(address=a.contract_address).call()
    assert owned_dust.result == (10,)


@pytest.mark.asyncio
async def test_light_star(dust_factory):
    contract, a, _ = dust_factory

    dust_collected = 5000
    dust_amount = 2000

    await contract.collect_dust(dust_collected).invoke(caller_address=a.contract_address)

    await contract.light_star(dust_amount).invoke(caller_address=a.contract_address)

    owned_dust = await contract.view_dust(address=a.contract_address).call()
    assert owned_dust.result == (dust_collected - dust_amount,)

    star_size = await contract.view_star(address=a.contract_address, slot=0).call()
    assert star_size.result == (dust_amount,)

    slot = await contract.view_slot(address=a.contract_address).call()
    assert slot.result == (1,)
