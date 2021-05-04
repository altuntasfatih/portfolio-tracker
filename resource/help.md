
*/help*         Help().
*/start*        Alias for `/help`.
*/create*       It creates a stock portfolio for you.
*/live*         It calculates your potfolio with live stocks prices.
*/get*          It returns your stock portfolio.
*/get_detail*   It returns your stock portfolio with detail.
*/add_stock*    It adds stock to your portfolio.
                    e.g. `/add\_stock stockId name count price`
                    (stockId must be same with exchange identifier)
*/delete_stock* It deletes stock from portfolie,
                    e.g. `/delete\_stock stockId`
*/set_alert*    It creates a alert for a stock. When it hits target, it sends notification to you.
                    e.g. `/set\_alert type stockId targetPrice`
                     (type -> upper\_limit or lower\_limit)
*/remove_alert* It removes a alert for your portfolio.
                    e.g. `/remove\_alert stockId`
*/get_alerts*   It returns active alerts for your portfolio.
*/destroy*      It deletes your stock portfolo.