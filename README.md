# Portfolio Tracker

It is a telegram bot that follows stocks' prices according to your portfolio. Also it supports custom alert conditions for your stocks.When condition hit it sends a notification to your telegram acount.

It supports only BIST(Borsa Istanbul). But you can add a new behavior for exchange api then it runs according to it.
(Current exchange api is [collect_api](https://collectapi.com/tr/api/economy/altin-doviz-ve-borsa-api) free version :) )

Behavior for Exchange Api
```
defmodule PortfolioTracker.ExchangeApi do
  @callback get_live_prices() :: {:ok, list} | any

  def get_live_prices() do
    Application.get_env(:portfolio_tracker, :exchange_api).get_live_prices()
  end
end
```
You can set config to decide which exchange api runs on which environment.
```
import Config

config :portfolio_tracker,
  exchange_api: PortfolioTracker.CollectApi,

import_config "dev.secret.exs"

```


## Bot
[<img width="398" alt="Screen Shot 2021-04-30 at 22 30 11" src="https://user-images.githubusercontent.com/13722649/116748942-daaa8280-aa08-11eb-8502-43f1bda81e2d.png">](https://t.me/foter_portfolio_tracker_bot)

[Try It](https://t.me/foter_portfolio_tracker_bot)

### How to use
1. Firstly you should create a portfolio.

2. Then you can add or remove any number of stocks to your portfolio.

3. Also you can add custom alerts to your portfolio.

4. You can learn current value of stocks.

5. You can get detail of your portfolio.<br>


### Bot Commands

| Commands         | Explanation                                                                  | Example        |
|:---------------- |:----------------------------------------------------------------------------:| :--------------|
| `/create`        | It creates a stock portfolio for you.                                        | `/create`      |
| `/get`           | It returns your stock portfolio.                                             | `/get`         |
| `/get_detail`    | It returns your stock portfolio with detail.                                 | `/get_detail`  |
| `/live`          | It calculates your potfolio with live stocks prices.                         | `/live`        |
| `/add_stock`     | It adds stock to your portfolio.                                             | `/add_stock stock_id name count price` (stock_id must be same with exchange identifier)  |
| `/delete_stock`  | It deletes stock from portfolie.                                             | `/delete_stock stock_id`        |
| `/set_alert`     | It creates a alert for a stock. When it hits target, it send notification to you.| `/set_alert type stock_id target_price`  (type -> upper_limit or lower_limit)           |
| `/get_alerts`    | It returns active alerts for your portfolio.                                 | `/get_alerts`   |
| `/start`         | Alias for `/help `                                                           | `/live`        |
| `/help`          | Help()                                                                       | `/help`        |
