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
  

#### Bot commads 

*  /create        -> it creates a stock portfolio for you.
*  /get           -> it gets your stock portfolio.
*  /live          -> it calculates your potfolio with live stocks prices.
*  /destroy       -> it deletes your stock portfolo.
*  /add_stock     -> it adds stock to your portfolio,
                  e.g. /add_stock stock_id name count price targetPrice
                  (stock_id must be same with exchange identifier)
*  /delete_stock  -> it deletes stock from portfolie,
                  e.g. /delete_stock stock_id
*  /help           -> help.

