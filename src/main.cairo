%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (get_caller_address, get_block_timestamp)
from starkware.cairo.common.uint256 import Uint256

@storage_var
func last_token_price() -> (res: felt) {
}

@storage_var
func periodicity() -> (res: felt) {
}

@storage_var
func last_execution() -> (res: felt) {
}

@storage_var
func amount_to_buy() -> (res: felt) {
}

const ETH_TOKEN = 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7;
const USDC_TOKEN = 0x005a643907b9a4bc6a55e9069c4fd5fd1f5c79a22470690f75556c4736e34426;

// Oracle Interface Definition
const EMPIRIC_ORACLE_ADDRESS = 0x446812bac98c08190dee8967180f4e3cdcd1db9373ca269904acb17f67f7093;
const PAIR_ID = 19514442401534788;  // str_to_felt("ETH/USD")

// Oracle  Interface
@contract_interface
namespace IEmpiricOracle {
    func get_spot_median(pair_id: felt) -> (
        price: felt, decimals: felt, last_update_timestamp: felt, num_sources_aggregated: felt
    ) {
    }
}

// MySwap Interface Definition
const SWAP_ADDRESS = 0x018a439bcbb1b3535a6145c1dc9bc6366267d923f60a84bd0c7618f33c81d334;

// MySwap Interface
@contract_interface
namespace ISwap {
    func swap(
        pool_id: felt, token_from_addr: felt, amount_from: Uint256, amount_to_min: Uint256
    ) -> (test: felt) {
    }
}

// Nostra Finance Interface - Currently Nostra Finance don't make publish his contracts
// We cannot make deposits in his AMM yet
const NOSTRA_AMM_ADDRESS = 0x0000000000000000;

// Get ETH price from EmpiricNetwork Oracle
@view
func get_token_price{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    current_price: felt
) {
    let (
        eth_price, decimals, last_update_timestamp, num_sources_aggregated
    ) = IEmpiricOracle.get_spot_median(EMPIRIC_ORACLE_ADDRESS, PAIR_ID);

    return (current_price=eth_price);
}

// This function has the logic for buy or sell.
@view
func get_action{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (current_price) = get_token_price();
    let (last_price) = last_token_price.read();

    tempvar action = is_le(last_price, current_price); // lp <= cp
    let (amount) = amount_to_buy.read();

    if(action == 0) {
        // buy eth
        let (result) = swap_bot(amount, amount - 1);
        return();
    }

    if(action == 1) {
        // sell eth
        let (result) = swap_bot(amount, amount - 1);
        return();
    }
    return ();
}

// get last time when the task was executed
@view
func last_executed{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() ->(_result: felt) {
    let (last_time_executed) = last_execution.read();
    return (_result = last_time_executed);
}

// Yagi Integration
@view
func probeTask{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (_taskReady: felt) {
    let (lastExecuted) = last_execution.read();
    let (block_time) = get_block_timestamp();
    let (_periodicity) = periodicity.read();
    let deadline = lastExecuted + (_periodicity * 84600);
    let taskReady = is_le(deadline, block_time);

    return(_taskReady = taskReady); 
}

// Set bot Params
@external
func set_bot_params{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _amount: felt, _periodicity: felt
) {
    amount_to_buy.write(_amount);
    periodicity.write(_periodicity);
    let (eth_price) = get_token_price();
    last_token_price.write(eth_price);

    return();
}

// Yagi Intergration
// Yagi Keepers call this function whe probeTask returns true
@external
func executeTask{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    get_action();
    let (get_time) = get_block_timestamp();
    last_execution.write(get_time);

    let (eth_price) = get_token_price();
    last_token_price.write(eth_price);

    return ();
}

func swap_bot{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount_from: felt, amount_to_min: felt) -> (
    response: felt
) {
    let (test) = ISwap.swap(
        SWAP_ADDRESS,
        1,
        2087021424722619777119509474943472645767659996348769578120564519014510906823,
        Uint256(amount_from, 0), // 1529265388067354
        Uint256(amount_to_min, 0), // 1529265388067354
    );
    return (response=test);
}
