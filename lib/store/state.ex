defmodule PortfolioTracker.State do
  require Logger

  @backup_path Application.get_env(:portfolio_tracker, :backup_path)

  def get(id) do
    case File.read(@backup_path <> "#{id}") do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      _ -> Portfolio.new(id)
    end
  end

  def save(id, %Portfolio{} = state) do
    binary = :erlang.term_to_binary(state)

    case File.write(@backup_path <> "#{id}", binary) do
      :ok -> Logger.info("State was succefully back up")
      {:error, err} -> Logger.error("Back up failed err -> #{err}")
    end
  end
end
