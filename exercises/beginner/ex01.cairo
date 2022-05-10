%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_le

# I AM NOT DONE

@storage_var
func dust(address : felt) -> (amount : felt):
end

# TODO
# Create two storages `star` and `slot`
# `slot` will map an `address` to the next available `slot` this `address` can use
# `star` will map an `address` and a `slot` to a `size`

# TODO
# Create an event `a_star_is_born`
# It will log:
# - the `account` that issued the transaction
# - the `slot` where this `star` has been registered
# - the size of the given `star`
# https://starknet.io/documentation/events/

@external
func collect_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : felt):
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
    dust_amount : felt
):
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
func view_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (amount : felt):
    let (res) = dust.read(address)
    return (res)
end

# TODO
# Write two views, for the `star` and `slot` storages

#########
# TESTS #
#########

@external
func test_collect_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    collect_dust(5)
    let (dust_amount) = view_dust(0)
    assert dust_amount = 5

    collect_dust(10)
    let (dust_amount) = view_dust(0)
    assert dust_amount = 15

    return ()
end

@external
func test_light_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    collect_dust(100)
    let (dust_amount) = view_dust(0)
    assert dust_amount = 100

    light_star(60)
    let (dust_amount) = view_dust(0)
    assert dust_amount = 40
    let (slot) = view_slot(0)
    assert slot = 1
    let (star_size) = view_star(0, 0)
    assert star_size = 60

    light_star(30)
    let (dust_amount) = view_dust(0)
    assert dust_amount = 10
    let (slot) = view_slot(0)
    assert slot = 2
    let (star_size) = view_star(0, 1)
    assert star_size = 30

    return ()
end

@external
func test_light_star_ko{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    collect_dust(100)
    let (dust_amount) = view_dust(0)
    assert dust_amount = 100

    %{ expect_revert() %}
    light_star(1000)
    let (dust_amount) = view_dust(0)
    assert dust_amount = 100
    let (slot) = view_slot(0)
    assert slot = 0

    return ()
end
