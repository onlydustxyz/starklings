import pytest
from starkware.starknet.testing.starknet import Starknet


@pytest.fixture
async def starknet() -> Starknet:
    return await Starknet.empty()
