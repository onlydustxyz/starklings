%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (get_caller_address)
from starkware.cairo.common.math import (assert_le)

@storage_var
func dust(address: felt) -> (amount: felt):
end

@storage_var
func star(address: felt, slot: felt) -> (size: felt):
end

@storage_var
func slot(address: felt) -> (slot: felt):
end


@event
func a_star_is_born(account: felt, slot: felt, size: felt):
end


@external
func collect_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : felt):
    let (address) = get_caller_address()

    let (res) = dust.read(address)
    dust.write(address, res + amount)

    return ()
end

@external
func light_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        dust_amount: felt):
    let (address) = get_caller_address()

    let (dust_reserve) = dust.read(address)
    assert_le(dust_amount, dust_reserve)

    dust.write(address, dust_reserve - dust_amount)

    let (current_slot) = slot.read(address)
    
    star.write(address, current_slot, dust_amount)
    
    slot.write(address, current_slot + 1)
    
    a_star_is_born.emit(address, current_slot, dust_amount)

    return ()
end


@view
func view_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (
        amount: felt):
    let (res) = dust.read(address)
    return (res)
end

@view
func view_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt, slot: felt) -> (
        size: felt):
    let (res) = star.read(address, slot)
    return (res)
end

@view
func view_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (
        amount: felt):
    let (res) = slot.read(address)
    return (res)
end