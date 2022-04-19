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
    rand = await deploy_contract(starknet, 'core/rand.cairo')
    dust = await deploy_contract(starknet, 'ex/ex02.cairo', constructor_calldata=[SPACE_CONTRACT, rand.contract_address])
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
async def test_mint_batch(dust_factory):
    dust, anyone, _ = dust_factory

    await assert_revert(dust.mint(metadata()).invoke(caller_address=anyone.contract_address), reverted_with='Ownable: caller is not the owner')

    # Mint 10 tokens
    execution_info = await dust.mint_batch([metadata() for i in range(10)]).invoke(caller_address=SPACE_CONTRACT)
    assert execution_info.result == (list(map(to_uint, range(10))),)

    # Check balance of owner
    execution_info = await dust.balanceOf(SPACE_CONTRACT).invoke()
    assert execution_info.result == (to_uint(10),)

    # Check the owner of minted tokens
    for i in map(to_uint, range(10)):
        execution_info = await dust.ownerOf(i).invoke()
        assert execution_info.result == (SPACE_CONTRACT,)


@pytest.mark.asyncio
async def test_mint_random_on_border(dust_factory):
    dust, anyone, _ = dust_factory

    # High number for random testing, but not too big as unit tests are sloooooowwww
    NB_TOKENS = 100
    SPACE_SIZE = 50

    await assert_revert(dust.mint_random_on_border(SPACE_SIZE).invoke(caller_address=anyone.contract_address), reverted_with='Ownable: caller is not the owner')

    # Mint NB_TOKENS tokens
    for i in map(to_uint, range(NB_TOKENS)):
        execution_info = await dust.mint_random_on_border(SPACE_SIZE).invoke(caller_address=SPACE_CONTRACT)
        assert execution_info.result == (i,)

    # Check balance of owner
    execution_info = await dust.balanceOf(SPACE_CONTRACT).invoke()
    assert execution_info.result == (to_uint(NB_TOKENS),)

    # Check the owner of minted tokens
    for i in map(to_uint, range(NB_TOKENS)):
        execution_info = await dust.ownerOf(i).invoke()
        assert execution_info.result == (SPACE_CONTRACT,)

    # Check the metadata
    all_positions = []
    all_directions = []
    for i in map(to_uint, range(NB_TOKENS)):
        execution_info = await dust.metadata(i).invoke()
        space_size, position, direction = execution_info.result.metadata
        all_positions.append(position)
        all_directions.append(direction)

        assert space_size == SPACE_SIZE
        (x, y) = position
        assert x == 0 or x == SPACE_SIZE-1 or y == 0 or y == SPACE_SIZE - \
            1  # mint should spawn on a border

        (x, y) = direction
        assert x in [-1 % MAX_FELT, 0, 1]  # direction is -1, 0, 1
        assert y in [-1 % MAX_FELT, 0, 1]  # direction is -1, 0, 1

    # Run pytest `--log-cli-level=INFO` to see those lines
    logging.info('Generated {} different positions: {}'.format(
        len(set(all_positions)), set(all_positions)))
    logging.info('Generated {} different directions: {}'.format(
        len(set(all_directions)), set(all_directions)))

    # Make sure they are "randomly" generated === several are different
    assert len(set(all_positions)) >= min(SPACE_SIZE, NB_TOKENS) / \
        2  # max 4*(SPACE_SIZE-1) positions or NB_TOKENS
    assert len(set(all_directions)) > 5  # max 9 directions
    assert len(set(x for x, _ in all_positions)) > min(
        SPACE_SIZE, NB_TOKENS)/4  # Some position.x are different
    assert len(set(y for _, y in all_positions)) > min(
        SPACE_SIZE, NB_TOKENS)/4  # Some position.y are different
    # Some direction.x are different
    assert len(set(x for x, _ in all_directions)) > 1
    # Some direction.y are different
    assert len(set(y for _, y in all_directions)) > 1


@pytest.mark.asyncio
async def test_mint_batch_random_on_border(dust_factory):
    dust, anyone, _ = dust_factory

    # High number for random testing, but not too big as unit tests are sloooooowwww
    NB_TOKENS = 100
    SPACE_SIZE = 50

    await assert_revert(dust.mint_batch_random_on_border(SPACE_SIZE, NB_TOKENS).invoke(caller_address=anyone.contract_address), reverted_with='Ownable: caller is not the owner')

    # Mint NB_TOKENS tokens
    execution_info = await dust.mint_batch_random_on_border(SPACE_SIZE, NB_TOKENS).invoke(caller_address=SPACE_CONTRACT)
    assert execution_info.result == (list(map(to_uint, range(NB_TOKENS))),)

    # Check balance of owner
    execution_info = await dust.balanceOf(SPACE_CONTRACT).invoke()
    assert execution_info.result == (to_uint(NB_TOKENS),)

    # Check the owner of minted tokens
    for i in map(to_uint, range(NB_TOKENS)):
        execution_info = await dust.ownerOf(i).invoke()
        assert execution_info.result == (SPACE_CONTRACT,)

    # Check the metadata
    all_positions = []
    all_directions = []
    for i in map(to_uint, range(NB_TOKENS)):
        execution_info = await dust.metadata(i).invoke()
        space_size, position, direction = execution_info.result.metadata
        all_positions.append(position)
        all_directions.append(direction)

        assert space_size == SPACE_SIZE
        (x, y) = position
        assert x == 0 or x == SPACE_SIZE-1 or y == 0 or y == SPACE_SIZE - \
            1  # mint should spawn on a border

        (x, y) = direction
        assert x in [-1 % MAX_FELT, 0, 1]  # direction is -1, 0, 1
        assert y in [-1 % MAX_FELT, 0, 1]  # direction is -1, 0, 1

    # Run pytest `--log-cli-level=INFO` to see those lines
    logging.info('Generated {} different positions: {}'.format(
        len(set(all_positions)), set(all_positions)))
    logging.info('Generated {} different directions: {}'.format(
        len(set(all_directions)), set(all_directions)))

    # Make sure they are "randomly" generated === several are different
    assert len(set(all_positions)) >= min(SPACE_SIZE, NB_TOKENS) / \
        2  # max 4*(SPACE_SIZE-1) positions or NB_TOKENS
    assert len(set(all_directions)) > 5  # max 9 directions
    assert len(set(x for x, _ in all_positions)) > min(
        SPACE_SIZE, NB_TOKENS)/4  # Some position.x are different
    assert len(set(y for _, y in all_positions)) > min(
        SPACE_SIZE, NB_TOKENS)/4  # Some position.y are different
    # Some direction.x are different
    assert len(set(x for x, _ in all_directions)) > 1
    # Some direction.y are different
    assert len(set(y for _, y in all_directions)) > 1


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


@pytest.mark.asyncio
async def test_move(dust_factory):
    dust, _, _ = dust_factory

    old_metadata = metadata(100, (10, 10), (1, 0))
    new_metadata = metadata(100, (11, 10), (1, 0))

    # Mint token
    execution_info = await dust.mint(old_metadata).invoke(caller_address=SPACE_CONTRACT)
    token_id = execution_info.result.token_id

    # Check metadata
    execution_info = await dust.metadata(token_id).invoke()
    assert execution_info.result == (old_metadata, )

    # Move the dust
    execution_info = await dust.move(token_id).invoke(caller_address=SPACE_CONTRACT)
    assert execution_info.result == (new_metadata,)

    # Check updated metadata
    execution_info = await dust.metadata(token_id).invoke()
    assert execution_info.result == (new_metadata,)


class Move:
    def __init__(self, old, new):
        self.old = old
        self.new = new


@pytest.fixture
def all_moves():
    return [
        Move(  # standard move
            old=metadata(space_size=100, position=(10, 10), direction=(1, 0)),
            new=metadata(space_size=100, position=(11, 10), direction=(1, 0))
        ),
        Move(  # move beyond right border horizontally
            old=metadata(space_size=100, position=(99, 10), direction=(1, 0)),
            new=metadata(space_size=100, position=(98, 10), direction=(-1, 0))
        ),
        Move(  # move aside right border vertically
            old=metadata(space_size=100, position=(99, 10), direction=(0, 1)),
            new=metadata(space_size=100, position=(99, 11), direction=(0, 1))
        ),
        Move(  # move beyond left border horizontally
            old=metadata(space_size=100, position=(0, 10), direction=(-1, 0)),
            new=metadata(space_size=100, position=(1, 10), direction=(1, 0))
        ),
        Move(  # move aside left border vertically
            old=metadata(space_size=100, position=(0, 10), direction=(0, 1)),
            new=metadata(space_size=100, position=(0, 11), direction=(0, 1))
        ),
        Move(  # move beyond top border vertically
            old=metadata(space_size=100, position=(10, 0), direction=(0, -1)),
            new=metadata(space_size=100, position=(10, 1), direction=(0, 1))
        ),
        Move(  # move aside top border horizontally
            old=metadata(space_size=100, position=(10, 0), direction=(1, 0)),
            new=metadata(space_size=100, position=(11, 0), direction=(1, 0))
        ),
        Move(  # move beyond bottom border vertically
            old=metadata(space_size=100, position=(10, 99), direction=(0, 1)),
            new=metadata(space_size=100, position=(10, 98), direction=(0, -1))
        ),
        Move(  # move aside bottom border horizontally
            old=metadata(space_size=100, position=(10, 99), direction=(1, 0)),
            new=metadata(space_size=100, position=(11, 99), direction=(1, 0))
        ),
        Move(  # move across top-right corner in diagonal
            old=metadata(space_size=100, position=(0, 0), direction=(-1, -1)),
            new=metadata(space_size=100, position=(1, 1), direction=(1, 1))
        ),
        Move(  # move across top-left corner in diagonal
            old=metadata(space_size=100, position=(99, 0), direction=(1, -1)),
            new=metadata(space_size=100, position=(98, 1), direction=(-1, 1))
        ),
        Move(  # move across bottom-right corner in diagonal
            old=metadata(space_size=100, position=(99, 99), direction=(1, 1)),
            new=metadata(space_size=100, position=(98, 98), direction=(-1, -1))
        ),
        Move(  # move across bottom-left corner in diagonal
            old=metadata(space_size=100, position=(0, 99), direction=(-1, 1)),
            new=metadata(space_size=100, position=(1, 98), direction=(1, -1))
        )
    ]


@pytest.mark.asyncio
async def test_move(dust_factory, all_moves):
    dust, _, _ = dust_factory
    for m in all_moves:
        # Mint token
        execution_info = await dust.mint(m.old).invoke(caller_address=SPACE_CONTRACT)
        token_id = execution_info.result.token_id

        # Check metadata
        execution_info = await dust.metadata(token_id).invoke()
        assert execution_info.result == (m.old, )

        # Move the dust
        execution_info = await dust.move(token_id).invoke(caller_address=SPACE_CONTRACT)
        assert execution_info.result == (m.new,)

        # Check updated metadata
        execution_info = await dust.metadata(token_id).invoke()
        assert execution_info.result == (m.new,)
