defmodule Telegram.MessageProcessorTest do
  use ExUnit.Case
  import StockListener.Telegram.MessageProcessor

  test "it_should_process_start_instruction" do
    assert process_message(create_message("start")) == "Stock listener was created for you"
  end

  test "it_should_process_add_instruction" do
    start()
    assert process_message(create_message("add VAKBN VAKIF_BANK 250 4.5 5")) == :ok
  end

  test "it_should_return_parse_error_when_add_args_is_invalid" do
    start()
    assert process_message(create_message("add VAKBN VAKIF_BANK x x as")) == "Parse error"
  end

  test "it_should_return_args_missing_when_add_args_is_invalid" do
    start()
    assert process_message(create_message("add")) == "Arg is missing"
  end

  test "it_should_not_process_when_listener_not_started" do
    assert process_message(create_message("get")) ==
             "There is no listener for you, if you want to create it , type \"start\" before any action"
  end

  #todo add test for current instruction

  def start() do
    assert process_message(create_message("start")) == "Stock listener was created for you"
  end

  def create_message(message), do: %{text: message, from: %{id: @id}}
end
