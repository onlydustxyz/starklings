from importlib_metadata import metadata
import pytest
import logging

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract
from starkware.starknet.public.abi import get_selector_from_name

from fixtures import *
from deploy import deploy_contract
from utils import assert_revert, str_to_felt, to_uint

SPACE_CONTRACT = get_selector_from_name('Space')


@pytest.fixture
async def dust_factory(starknet: Starknet) -> StarknetContract:
    dust = await deploy_contract(starknet, 'ex/ex00.cairo', constructor_calldata=[SPACE_CONTRACT])
    account1 = await deploy_contract(starknet, 'openzeppelin/token/erc721/utils/ERC721_Holder.cairo')
    account2 = await deploy_contract(starknet, 'openzeppelin/token/erc721/utils/ERC721_Holder.cairo')

    return dust, account1, account2

MAX_FELT = 2**251 + 17 * 2**192 + 1

#
# Constructor
#


def metadata(space_size=100, position=(10, 10), direction=(1, 0)):
    return space_size, tuple(x % MAX_FELT for x in position), tuple(x % MAX_FELT for x in direction)


@pytest.mark.asyncio
async def test_constructor(dust_factory):
    dust, _, _ = dust_factory

    execution_info = await dust.name().invoke()
    assert execution_info.result == (str_to_felt("Dust Non Fungible Token"),)

    execution_info = await dust.symbol().invoke()
    assert execution_info.result == (str_to_felt("DUST"),)


@pytest.mark.asyncio
async def test_mint(dust_factory):
    dust, anyone, _ = dust_factory

    await assert_revert(dust.mint(metadata()).invoke(caller_address=anyone.contract_address), reverted_with='Ownable: caller is not the owner')

    # Mint 10 tokens
    for i in map(to_uint, range(10)):
        execution_info = await dust.mint(metadata()).invoke(caller_address=SPACE_CONTRACT)
        assert execution_info.result == (i,)

    # Check balance of owner
    execution_info = await dust.balanceOf(SPACE_CONTRACT).invoke()
    assert execution_info.result == (to_uint(10),)

    # Check the owner of minted tokens
    for i in map(to_uint, range(10)):
        execution_info = await dust.ownerOf(i).invoke()
        assert execution_info.result == (SPACE_CONTRACT,)


@pytest.mark.asyncio
async def test_burn(dust_factory):
    dust, anyone, _ = dust_factory

    # Mint 2 tokens
    for i in map(to_uint, range(2)):
        execution_info = await dust.mint(metadata()).invoke(caller_address=SPACE_CONTRACT)
        assert execution_info.result == (i,)

    # Cannot burn if not owner
    await assert_revert(dust.burn(to_uint(0)).invoke(caller_address=anyone.contract_address), reverted_with='Ownable: caller is not the owner')

    # Burn token 0
    await dust.burn(to_uint(0)).invoke(caller_address=SPACE_CONTRACT)

    # Check balance of owner
    execution_info = await dust.balanceOf(SPACE_CONTRACT).invoke()
    assert execution_info.result == (to_uint(1),)

    # Check the owner of minted tokens
    await assert_revert(dust.ownerOf(to_uint(0)).invoke(), reverted_with='ERC721: owner query for nonexistent token')

    execution_info = await dust.ownerOf(to_uint(1)).invoke()
    assert execution_info.result == (SPACE_CONTRACT,)


@pytest.mark.asyncio
async def test_transfer(dust_factory):
    dust, ship1, ship2 = dust_factory

    # Allow space to transfer tokens between ships
    await dust.setApprovalForAll(SPACE_CONTRACT, 1).invoke(caller_address=ship1.contract_address)
    await dust.setApprovalForAll(SPACE_CONTRACT, 1).invoke(caller_address=ship2.contract_address)

    # Mint token
    execution_info = await dust.mint(metadata()).invoke(caller_address=SPACE_CONTRACT)
    token_id = execution_info.result.token_id

    # Check balances
    execution_info = await dust.balanceOf(SPACE_CONTRACT).invoke()
    assert execution_info.result == (to_uint(1),)

    execution_info = await dust.balanceOf(ship1.contract_address).invoke()
    assert execution_info.result == (to_uint(0),)

    execution_info = await dust.ownerOf(token_id).invoke()
    assert execution_info.result == (SPACE_CONTRACT,)

    # transfer token (Space -> ship1)
    await dust.safeTransferFrom(SPACE_CONTRACT, ship1.contract_address, token_id).invoke(caller_address=SPACE_CONTRACT)

    # Check balances
    execution_info = await dust.balanceOf(SPACE_CONTRACT).invoke()
    assert execution_info.result == (to_uint(0),)

    execution_info = await dust.balanceOf(ship1.contract_address).invoke()
    assert execution_info.result == (to_uint(1),)

    execution_info = await dust.ownerOf(token_id).invoke()
    assert execution_info.result == (ship1.contract_address,)

    # transfer token (ship1 -> ship2)
    await dust.safeTransferFrom(ship1.contract_address, ship2.contract_address, token_id).invoke(caller_address=SPACE_CONTRACT)

    # Check balances
    execution_info = await dust.balanceOf(ship1.contract_address).invoke()
    assert execution_info.result == (to_uint(0),)

    execution_info = await dust.balanceOf(ship2.contract_address).invoke()
    assert execution_info.result == (to_uint(1),)

    execution_info = await dust.ownerOf(token_id).invoke()
    assert execution_info.result == (ship2.contract_address,)
