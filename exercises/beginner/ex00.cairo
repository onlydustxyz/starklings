%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

# I AM NOT DONE

# TODO
# Create a storage named `dust` that map an `address` to an `amount`
# https://starknet.io/documentation/contracts/#contracts_storage
# https://www.cairo-lang.org/docs/hello_starknet/intro.html
# https://www.cairo-lang.org/docs/hello_starknet/user_auth.html#storage-maps

# This code block define an `external` function
# It can be called by other contracts (wallet or other)
@external
func collect_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : felt):
    # Get the address of the account that issued the call
    # https://www.cairo-lang.org/docs/hello_starknet/user_auth.html#getting-the-caller-address
    let (address) = get_caller_address()

    # Read the amount of dust this user own (it's read from the storage you have to create)
    # Default value is 0 for all uninitialized keys
    let (res) = dust.read(address)

    # Write back the increased value
    dust.write(address, res + amount)

    return ()
end

# This code block define a view
# It's can be called from outside the runtime, but without the need to sign the transaction
# It cannot write ton the storage, just read form it
# Except for this limitation, they can still do computation and be fairly complex
@view
func view_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (amount : felt):
    let (res) = dust.read(address)
    return (res)
end
