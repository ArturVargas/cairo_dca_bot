%lang starknet
from starkware.cairo.common.math import assert_nn, assert_not_zero
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_le, uint256_add, uint256_sub

// mapping in cairo
@storage_var
func balance(account: felt) -> (balance: felt) {
}

@storage_var
func last_token_price() -> (res: felt) {
}

@storage_var
func up_variation() -> (res: felt) {
}

@storage_var
func down_variation() -> (res: felt) {
}

@storage_var
func periodicity() -> (res: felt) {
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
const MY_SWAP_ADDRESS = 0x018a439bcbb1b3535a6145c1dc9bc6366267d923f60a84bd0c7618f33c81d334;

// MySwap Interface
@contract_interface
namespace IMySwap {
    func swap(
        pool_id: felt, token_from_addr: felt, amount_from: Uint256, amount_to_min: Uint256
    ) -> (test: felt) {
    }
}

// Nostra Finance Interface
const NOSTRA_AMM_ADDRESS = 0x0000000000000000;
// Have I to send tokenA, tokenB and amount?

// deposit to contract and make swap 50/50
// get amount on tokenA and make swap 50% to tokenB
// @external
// func deposit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
//     tokenA: felt, tokenB: felt, amount: felt
// ) {
//     with_attr error_message("Amount must be positive. Got: {amount}.") {
//         assert_nn(amount);
//     }
//     // divide amount.
//     // swap by tokenB
//     // balance update
//     return ();
// }

@external
func dca_buy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    // se consulta el oraculo con respecto a tokenB y se compara con respecto al ultimo precio
    // en caso de que tokenB haya bajado más o igual al down_variation se toma un monto de tokenA y se
    // compra de tokenB si el tokenB subio más o igual al up_variation se toma un monto de tokenB y se cambia
    // por tokenA
    // EJ. tokenA = USDC tokenB = ETH
    //  Se deposita en el pool de nostra finance.
    return ();
}

@external
func swap_bot{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount_from: felt, amount_to_min: felt) -> (
    response: felt
) {
    let (test) = IMySwap.swap(
        MY_SWAP_ADDRESS,
        1,
        2087021424722619777119509474943472645767659996348769578120564519014510906823,
        Uint256(amount_from, 0), // 1529265388067354
        Uint256(amount_to_min, 0), // 1529265388067354
    );
    return (response=test);
}

@view
func get_token_price{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    current_price: felt
) {
    let (
        eth_price, decimals, last_update_timestamp, num_sources_aggregated
    ) = IEmpiricOracle.get_spot_median(EMPIRIC_ORACLE_ADDRESS, PAIR_ID);

    return (current_price=eth_price);
}

@view
func get_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt
) -> (res: felt) {
    let (res) = balance.read(account);
    return (res,);
}

// SC: 0x2b9a71350b7195e9bb2350d409b047f1e74bb652db69b49d688d59e75eed287

// MySwap
// [
//   "1", - pool_id
//   "2087021424722619777119509474943472645767659996348769578120564519014510906823", token_from_addr
//   "3781790703593631", - amount from
//   "0",
//   "1960000", - amount to min
//   "0"
// ]

// SithSwap -swapExactTokensForTokensSupportingFeeOnTransferTokens
// [
//   "6000000000000000", - Eth en Wei

// "271289", - amount out min in usdc

// "1", - routes len
//   [
//     {
//         "2087021424722619777119509474943472645767659996348769578120564519014510906823",
//         "159707947995249021625440365289670166666892266109381225273086299925265990694",
//         "0",
//     }
//   ]
//   "980032196447177943098570450793630356269173730602706106888817574652304964803", - to
//   "1666907459"  - deadline
// ]
//
