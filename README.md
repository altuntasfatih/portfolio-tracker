# Portfolio Tracker

It is a Telegram bot that follows asset's prices according to your portfolio.
Also it supports custom alert conditions for your thresholds. When condition hits, it sends a notification to your telegram acount.

Currently it supports two types of asset which  are :bist(a.k.a The Borsa İstanbul) and :crypto(Crypto currency).

To fetch live price of Bist's stocks the [Collect_Api](https://collectapi.com/tr/api/economy/altin-doviz-ve-borsa-api) is using.

To fetch live price of Cryptocurrencies the [CoinGecko](https://www.coingecko.com/en/api) is using.

## Bot
[<img width="398" alt="Screen Shot 2021-04-30 at 22 30 11" src="https://user-images.githubusercontent.com/13722649/116748942-daaa8280-aa08-11eb-8502-43f1bda81e2d.png">](https://t.me/foter_portfolio_tracker_bot)

[Try It](https://t.me/foter_portfolio_tracker_bot)


### How to use
1. Firstly you should create a portfolio.
2. Then you can add or remove any number of assets to your portfolio.
3. Also you can add or remove custom alerts for your assets.
4. You can learn and watch current value of your assets.

<img width="410" alt="Screen Shot 2021-05-12 at 19 38 35" src="https://user-images.githubusercontent.com/13722649/118012635-f0e60600-b359-11eb-969c-c0209764e21a.png">


### Bot Commands

| Commands          | Explanation                                                                      | Example        |
|:----------------  |:-------------------------------------------------------------------------------: | :--------------|
| `/create`         | It creates a portfolio for you.                                                  | `/create`      |
| `/get`            | It returns your portfolio.                                                       | `/get`         |
| `/get_detail`     | It returns your portfolio with detail.                                           | `/get_detail`  |
| `/live`           | It calculates your potfolio with live  prices.                                   | `/live`        |
| `/get_asset_types`| It returns supported asset types                                                 | `/get_asset_types`  |
| `/add_asset`      | It adds asset to your portfolio.                                                 | `/add_asset type name count price` (name must be same with exchange identifier)  |
| `/delete_asset`  | It deletes asset from portfolie.                                                 | `/delete_asset name`        |
| `/set_alert`     | It creates a alert for a asset. When it hits target, it send notification to you.| `/set_alert type name target_price`  (type -> upper_limit or lower_limit)           |
| `/get_alerts`     | It returns active alerts for your portfolio.                                     | `/get_alerts`  |
| `/start`          | Alias for `/help `                                                               | `/live`        |
| `/help`           | Help()                                                                           | `/help`        |

