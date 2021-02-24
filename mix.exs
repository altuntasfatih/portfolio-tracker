defmodule StockListener.MixProject do
  use Mix.Project

  def project do
    [
      app: :stock_listener,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {StockListener.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.7.0"},
      {:nadia, "~> 0.7.0"},
      {:jason, "~> 1.2"}
    ]
  end
end
