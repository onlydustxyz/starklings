%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_le

struct Star:
    member name : felt
    member size : felt
end

@storage_var
func dust(address : felt) -> (amount : felt):
end

@storage_var
func star(address : felt, slot : felt) -> (star : Star):
end

@storage_var
func slot(address : felt) -> (slot : felt):
end

@event
func a_star_is_born(account : felt, slot : felt, size : Star):
end

@external
func collect_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : felt):
    let (address) = get_caller_address()

    let (res) = dust.read(address)
    dust.write(address, res + amount)

    return ()
end

@external
func light_stars{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        stars_len : felt, stars : Star*):
    let (address) = get_caller_address()

    batch_create_stars(address, stars_len, stars)

    return ()
end

func batch_create_stars{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, array_len : felt, array : Star*):
    # Successively insert all the array stars in the storage
    # There is no loops in cairo, we use recursion
    # https://www.cairo-lang.org/docs/hello_starknet/more_features.html#array-arguments-in-calldata
    # The stars must be inserted in same order as they appear in the array

    # TODO
    # Write a stop condition
    # Insert the star at index 0 of the array
    # recursively call `batch_create_stars`

    return ()
end

func insert_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, new_star : Star):
    let (dust_reserve) = dust.read(address)
    assert_le(new_star.size, dust_reserve)

    dust.write(address, dust_reserve - new_star.size)

    let (current_slot) = slot.read(address)

    star.write(address, current_slot, new_star)

    slot.write(address, current_slot + 1)

    a_star_is_born.emit(address, current_slot, new_star)

    return ()
end

@view
func view_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt) -> (amount : felt):
    let (res) = dust.read(address)
    return (res)
end

@view
func view_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, slot : felt) -> (star : Star):
    let (res) = star.read(address, slot)
    return (res)
end

@view
func view_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt) -> (amount : felt):
    let (res) = slot.read(address)
    return (res)
end
