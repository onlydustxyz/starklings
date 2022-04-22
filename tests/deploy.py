import os
from starkware.starknet.testing.contract import StarknetContract
from starkware.starknet.testing.starknet import Starknet
from fixtures import starknet
from utils import contract_path


async def deploy_contract(starknet: Starknet, file_path, **kwargs) -> StarknetContract:
    return await starknet.deploy(
        source=contract_path(file_path),
        **kwargs,
    )
