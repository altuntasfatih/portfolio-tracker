defmodule PortfolioTracker.MessageHandlerTest do
  use ExUnit.Case
  alias PortfolioTracker.Bot.MessageHandler
  alias PortfolioTracker.Supervisor

  @from "testUser"
  setup do
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

    test "it should handle add_asset message", _ do
      assert MessageHandler.handle(:add_asset, ["Ripple", "250", "4.5"], @from) ==
               :ok
    end

    test "it should return args parse error", _ do
      assert MessageHandler.handle(:add_asset, ["Ethereum", "x", "x"], @from) ==
               {:error, :args_parse_error}
    end

    test "it should return args missing error", _ do
      assert MessageHandler.handle(:add_asset, [], @from) == {:error, :missing_parameter}
    end

    test "it should handle delete_asset message", _ do
      assert MessageHandler.handle(:delete_asset, ["VAKBN"], @from) == :ok
    end

    test "it should handle get message", _ do
      assert MessageHandler.handle(:get, [], @from) ==
               "Your portfolio:\n\nTotal value: 0.0 USD\nRate: +% 0.0 🟢"
    end

    test "it should return portfolio not found error", _ do
      assert MessageHandler.handle(:get, [], %{id: 2}) == {:error, :portfolio_not_found}
    end

    test "it should handle alert messages" do
      assert MessageHandler.handle(:set_alert, ["upper_limit", "dot", "42.67"], @from) ==
               :ok

      assert MessageHandler.handle(:remove_alert, ["dot"], @from) == :ok
      assert MessageHandler.handle(:get_alerts, [], @from) == {:ok, []}

      assert MessageHandler.handle(:set_alert, ["lower_limit", "TEST", "10.67"], @from) ==
               :ok

      assert {:ok, [_ | _]} = MessageHandler.handle(:get_alerts, [], @from)
    end
  end

  describe "parse/1" do
    test "it should split message into command and aguments" do
      assert MessageHandler.parse_command("/add_asset VAKBN VAKIF_BANK 250 4.5") ==
               {:add_asset, ["VAKBN", "VAKIF_BANK", "250", "4.5"]}

      assert MessageHandler.parse_command("/remove_alert test") == {:remove_alert, ["test"]}
      assert MessageHandler.parse_command("/get") == {:get, []}
    end
  end
end
