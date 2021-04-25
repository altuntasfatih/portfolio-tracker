# Portfolio Tracker

### It is a telegram bot that follows stocks' prices according to your portfolio.
It supports only BIST(Borsa Istanbul). But you can add a new behavior for stock api then it runs according to it.  

```
defmodule PortfolioTracker.StockApi do
  @callback get_live_prices() :: {:ok, list} | any -> callback to get stock's live prices
  
   def get_live_prices() do
    Application.get_env(:portfolio_tracker, :stock_api).stock_prices()
  end
 
end
```
  
## Bot
[Try It ](https://t.me/foter_portfolio_tracker_bot)

### Commads 

*  /create        -> it creates a stock portfolio for you.
*  /get           -> it returns your stock portfolio.
*  /get_detail    -> it returns your stock portfolio with detail.
*  /live          -> it calculates your potfolio with live stocks prices.
*  /destroy       -> it deletes your stock portfolo.
*  /add_stock     -> it adds stock to your portfolio,
                  e.g. /add_stock stock_id name count price
                  (stock_id must be same with exchange identifier)
* /set_alert      -> it creates a alert for stock price in your portfolio. When it hits target, it send notification to you.
                  e.g. /set_alert stock_id target_price              
*  /delete_stock  -> it deletes stock from portfolie,
                  e.g. /delete_stock stock_id
*  /help           -> help.

