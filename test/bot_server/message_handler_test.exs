defmodule PortfolioTracker.MessageHandlerTest do
  use ExUnit.Case
  alias PortfolioTracker.MessageHandler
  alias PortfolioTracker.Supervisor

  @from %{id: 1}

  setup do
    {:ok, _} = PortfolioTracker.MockExchangeApi.start_link()
    on_exit(fn -> Supervisor.termine_all() end)
  end

  describe "handle/3" do
    test "it should handle create message" do
      assert MessageHandler.handle(:create, [], @from) == {:ok, :portfolio_created}
    end

    test "it should handle help message" do
      refute MessageHandler.handle(:help, [], nil) == ""
    end

    test "it should handle start message" do
      assert MessageHandler.handle(:start, [], nil) == MessageHandler.handle(:help, [], nil)
    end

    test "it should return instruction not found error" do
      assert MessageHandler.handle(:not_found, [], nil) == {:error, :instruction_not_found}
    end
  end

  describe "handle/3 with tracker" do
    setup do
      {:ok, :portfolio_created} = MessageHandler.handle(:create, [], @from)
      :ok
    end

    test "it should return portfolio already created", _ do
      assert MessageHandler.handle(:create, [], @from) == {:error, :portfolio_already_created}
    end

    test "it should handle destroy message", _ do
      assert MessageHandler.handle(:destroy, [], @from) == :ok
    end

    test "it should handle add_stock message", _ do
      assert MessageHandler.handle(:add_stock, ["VAKBN", "VAKIF_BANK", "250", "4.5"], @from) ==
               :ok
    end

    test "it should return args parse error", _ do
      assert MessageHandler.handle(:add_stock, ["VAKBN", "VAKIF_BANK", "x", "x"], @from) ==
               {:error, :args_parse_error}
    end

    test "it should return args missing error", _ do
      assert MessageHandler.handle(:add_stock, [], @from) == {:error, :missing_parameter}
    end

    test "it should handle delete_stock message", _ do
      assert MessageHandler.handle(:delete_stock, ["VAKBN"], @from) == :ok
    end

    test "it should handle get message", _ do
      assert MessageHandler.handle(:get, [], @from) ==
        {:ok, "Your Portfolio  \nValue: 0.0 \nUpdate Time:  \nRate: 0.0 🟢 "}
    end

    test "it should return portfolio not found error", _ do
      assert MessageHandler.handle(:get, [], %{id: 2}) == {:error, :portfolio_not_found}
    end

    test "it should handle alert messages" do
      assert MessageHandler.handle(:set_alert, ["upper_limit", "TOASO", "42.67"], @from) == :ok
      assert MessageHandler.handle(:remove_alert, ["TOASO"], @from) == :ok

      assert MessageHandler.handle(:get_alerts, [], @from) == {:ok, "Empty"}

      assert MessageHandler.handle(:set_alert, ["lower_limit", "TEST", "10.67"], @from) == :ok

      assert MessageHandler.handle(:get_alerts, [], @from) ==
               {:ok, "For TEST lower_limit on 10.67 "}
    end
  end

  describe "parse/1" do
    test "it should split message into arguments" do
      assert MessageHandler.parse("/add_stock VAKBN VAKIF_BANK 250 4.5") ==
               {:add_stock, ["VAKBN", "VAKIF_BANK", "250", "4.5"]}

      assert MessageHandler.parse("/remove_alert test") == {:remove_alert, ["test"]}
      assert MessageHandler.parse("/get") == {:get, []}
    end
  end

  """
  # test "it_should_process_live_instruction" do
  #  assert process_message(create_message("/live")) == " "
  # end

  def start() do
    assert consume_message(create_message("/create")) == "Portfolio tracker was created for you"
  end

  def create_message(message), do: %{text: message, from: %{id: @id}}
  """
end
