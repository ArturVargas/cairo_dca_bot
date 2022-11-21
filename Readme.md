# Experimental DCA BOT

This a contract to create a bot for making Dollar Cost Average in Automated way. **Just for fun**  

## Main Idea

The idea is has a bot that gets the price from ETH/USD price from [Empiric Oracle](https://empiric.network/) and when the price goes down the bot execute a swap from usd-stablecoin to ETH with [MySwap](https://www.myswap.xyz/#/), and when the price goes up the bot sell an amount from ETH to USD, We add automation task with [Yagi Finance](https://docs.yagi.fi/developers/automation/how-it-works) and deposit in [Nostra finance](https://nostra.finance/) to generate some APY (Soon!).

### [Contract Deployed](https://testnet.starkscan.co/contract/0x013978ae7d6de927738b7a2ab3406954e44892182376114804b5ff0ed0653c37#overview)

### Storage Variables

``last_token_price`` -> save the last token price that the oracle gets.  
``periodicity`` -> time interval to get the price from the oracle and execute a swap.  
``last_executed`` -> get the time when the task was executed for the last time.  

``amount_to_buy`` -> the amount that user want's to buy every swap.
``ETH Token Address`` -> 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7  
``USDC Token Address`` -> 0x005a643907b9a4bc6a55e9069c4fd5fd1f5c79a22470690f75556c4736e34426

## Contract Interfaces

- Empiric Network, ``get_spot_median``.  
- MySwap, ``swap``.
- Nostra Finance, ``deposits``, soon..!

## View Functions

### get_token_price

Get ETH price from EmpiricNetwork Oracle

```rust
@view
func get_token_price{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    current_price: felt
) {
    let (
        eth_price, decimals, last_update_timestamp, num_sources_aggregated
    ) = IEmpiricOracle.get_spot_median(EMPIRIC_ORACLE_ADDRESS, PAIR_ID);

    return (current_price=eth_price);
}
```

### get_action

This function obtains the current eth price from empiric network oracle and the price from eth last time that task was executed, and check if the current price is greater than last price then sell some eth, if not buy some eth to call `swap_bot` function.

```rust
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
```

### last_executed

Get last time when the task was executed

```rust
@view
func last_executed{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() ->(_result: felt) {
    let (last_time_executed) = last_execution.read();
    return (_result = last_time_executed);
}
```

## External Functions

### set_bot_params

Give the params for the bot will be working properly

- _amount: refers about the amount in usdc to swap by ether.
- _percent: is the time interval when the task will be executed.

```rust
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
```

### executeTask

Is the function that Yagi Keepers will be looking for execute the task.

 ```rust
 @external
func executeTask{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    get_action();
    let (get_time) = get_block_timestamp();
    last_execution.write(get_time);

    let (eth_price) = get_token_price();
    last_token_price.write(eth_price);

    return ();
}
 ```
