# StockListener

### It is a telegram bot that follow stocks' prices according to your portfolio.
It supports only BIST(Borsa Istanbul) however you can implement behavior which is in the below for any other exchange.

```
defmodule StockListener.StockApi do
  @callback stock_prices() :: {:ok, list} | any -> behavior to get stock prices
  
   def stock_prices() do
    Application.get_env(:stock_listener, :stock_api).stock_prices()
  end
 
end
```
  

#### Bot commads 

*  /start   -> it starts new stock lister for you.
*  /get     -> it gets your stock portfolio.
*  /live    -> it gets your stock portfolio with live stock prices.
*  /add     -> it adds stock to your portfolio,
                  e.g. /add id name count price targetPrice
                  (id must be same with exchangesId)
*  /delete  -> it deletes stock from portfolie,
                  e.g. /delete id
*  /help    -> help.

