%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (get_caller_address)
from starkware.cairo.common.math import (assert_le)

@storage_var
func dust(address: felt) -> (amount: felt):
end

# TODO
# Create two storages `star` and `slot`
# `star` will map an `address` and a `slot` to a `size`
# `slot` will map an `address` to the next available `slot` this `address` can use

# TODO
# Create an event `a_star_is_born`
# It will log:
# - the `account` that issued the transaction 
# - the `slot` where this `star` has been registered
# - the size of the given `star`
# https://starknet.io/documentation/events/

@external
func collect_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : felt):
    let (address) = get_caller_address()

    let (res) = dust.read(address)
    dust.write(address, res + amount)

    return ()
end

# This external allow an user to create a `star` by destroying an amount of `dust`
# The resulting star will have a `size` equal to the amount of `dust` used
# By the way, here is some doc about implicit arguments. Worth reading.
# https://starknet.io/docs/how_cairo_works/builtins.html
@external
func light_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        dust_amount: felt):
    # TODO
    # Get the caller address
    # Get the amount on dust owned by the caller
    # Make sure this amount is at least equal to `dust_amount`
    # Get the caller next available `slot`
    # Update the amount of dust owned by the caller
    # Register the newly created star, with a size equal to `dust_amount`
    # Increment the caller next available slot
    # Emit an `a_star_is_born` even with appropiate valued

    return ()
end


@view
func view_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (
        amount: felt):
    let (res) = dust.read(address)
    return (res)
end

#TODO
# Write two views, for the `star` and `slot` storages