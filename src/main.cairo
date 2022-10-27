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

// 10k Swap Interface Definition
const TENK_SWAP_ADDRESS = 0x00975910cd99bc56bd289eaaa5cee6cd557f0ddafdb2ce6ebea15b158eb2c664;

// 10K Swap Interface
@contract_interface
namespace I10kSwap {
    func swapExactTokensForTokens(
        amountIn: Uint256,
        amountOutMin: Uint256,
        path_len: felt,
        path: felt*,
        to: felt,
        deadline: felt,
    ) {
    }
}

// Nostra Finance Interface
const NOSTRA_SWAP_ADDRESS = 0x0000000000000000;
// Have I to send tokenA, tokenB and amount?

// deposit to contract and make swap 50/50
// get amount on tokenA and make swap 50% to tokenB
@external
func deposit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenA: felt, tokenB: felt, amount: felt
) {
    with_attr error_message("Amount must be positive. Got: {amount}.") {
        assert_nn(amount);
    }
    // divide amount.
    // swap by tokenB
    // balance update
    return ();
}

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
func set_config{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    up_var: felt, down_var: felt, interval: felt, dca_amount: felt
) {
    with_attr error_message("Up Variation must be greater than zero. Got: {up_var}.") {
        assert_nn(up_var);
    }
    with_attr error_message("Down Variation must be greater than zero. Got: {down_var}.") {
        assert_nn(down_var);
    }
    with_attr error_message("Interval must be greater than zero. Got: {interval}.") {
        assert_nn(interval);
    }

    // interval 3, 7, 14, 30
    // set storage
    up_variation.write(up_var);
    down_variation.write(down_var);
    periodicity.write(interval);
    amount_to_buy.write(dca_amount);

    return ();
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

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (sender) = get_caller_address();

    balance.write(sender, 0);

    return ();
}
