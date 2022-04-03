ExUnit.start()
ExUnit.configure(exclude: :pending, trace: true)

Mox.defmock(PortfolioTracker.CryptoMock, for: PortfolioTracker.Crypto.Api)
Application.put_env(:portfolio_tracker, :crypto, api: PortfolioTracker.CryptoMock)
