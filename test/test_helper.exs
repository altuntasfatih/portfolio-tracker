ExUnit.start()
ExUnit.configure(exclude: :pending, trace: true)

Mox.defmock(PortfolioTracker.CryptoMock, for: PortfolioTracker.Crypto.Api)
Mox.defmock(PortfolioTracker.BistMock, for: PortfolioTracker.Bist.Api)

Application.put_env(:portfolio_tracker, :crypto, api: PortfolioTracker.CryptoMock)
Application.put_env(:portfolio_tracker, :bist, api: PortfolioTracker.BistMock)
