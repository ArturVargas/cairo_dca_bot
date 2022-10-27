# Experimental DCA BOT

This a contract to create a bot for making Dollar Cost Average in Automated way. **Just for fun**  

## Main Idea

The idea is has a bot that gets the price from ETH/USD price from [Empiric Oracle](https://empiric.network/) and when the price goes down the bot execute a swap from usd-stablecoin to ETH with [10k Swap](https://github.com/10k-swap/10k_swap-contracts), and when the price goes up the bot sell an amount from ETH to USD and in both case deposit in [Nostra finance](https://nostra.finance/) to generate some APY.

### Storage Variables

``balance`` -> mapping the user's balance.  
``last_token_price`` -> save the last token price that the oracle gets.  
``up_variation`` -> the percentage price rice expected to executed a swap.  
``down_variation`` -> the percentage price down expected to executed a swap.
``periodicity`` -> time interval to get the price from the oracle and execute a swap.  
``amount_to_buy`` -> the amount that user want's to buy every swap.

### Contract Interfaces

- Empiric Network, ``get_spot_median``.  
- Nostra Finance, ``swap & deposit``, soon..!

### External Functions

The Function `set_config` setting all the parameters that the user has provided:  

- up_var: percentage price rice.
- down_var: percentage price down.
- interval: periods of time when the bot checkout the price and execute the swap.
- dca_amount: quantity of tokens to sell or buy in usd.
