%lang starknet

from starkware.cairo.common.uint256 import Uint256

from contracts.models.common import Dust

@contract_interface
namespace IDustContract:
    func name() -> (name : felt):
    end

    func symbol() -> (symbol : felt):
    end

    func mint(metadata : Dust) -> (token_id : Uint256):
    end

    func mint_random_on_border(space_size : felt) -> (token_id : Uint256):
    end

    func mint_batch(metadatas_len : felt, metadatas : Dust*) -> (
        token_id_len : felt, token_id : Uint256*
    ):
    end

    func mint_batch_random_on_border(space_size : felt, nb_tokens : felt) -> (token_id : Uint256):
    end

    func burn(token_id : Uint256):
    end

    func balanceOf(owner : felt) -> (balance : Uint256):
    end

    func ownerOf(tokenId : Uint256) -> (owner : felt):
    end

    func safeTransferFrom(from_ : felt, to : felt, tokenId : Uint256):
    end

    func setApprovalForAll(operator : felt, approved : felt):
    end

    func isApprovedForAll(owner : felt, operator : felt) -> (isApproved : felt):
    end

    func metadata(token_id : Uint256) -> (metadata : Dust):
    end

    func move(token_id : Uint256) -> (metadata : Dust):
    end
end
