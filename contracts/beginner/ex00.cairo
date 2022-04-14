%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (get_caller_address)

@storage_var
func dust(address: felt) -> (amount: felt):
end

@external
func collect_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : felt):
    let (address) = get_caller_address()

    let (res) = dust.read(address)
    dust.write(address, res + amount)

    return ()
end

@view
func view_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (
        amount: felt):
    let (res) = dust.read(address)
    return (res)
end
