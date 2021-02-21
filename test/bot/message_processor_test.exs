defmodule Telegram.MessageProcessorTest do
  use ExUnit.Case
  import Bot.MessageProcessor

  test "it_should_start_listener" do
    assert process_message(create_message("/start")) == "Stock listener was created for you"
  end

  test "it_should_return_listener_already_started" do
    start()

    assert process_message(create_message("/start")) ==
             "Your stock listener have already been created"
  end

  test "it_should_add_stock" do
    start()
    assert process_message(create_message("/add VAKBN VAKIF_BANK 250 4.5 5")) == :ok
  end

  test "it_should_return_parse_error_when_add_args_is_invalid" do
    start()

    assert process_message(create_message("/add VAKBN VAKIF_BANK x x as")) ==
             "Argumet/Arguments formats are invalid"
  end

  test "it_should_return_args_missing_when_add_args_is_invalid" do
    start()
    assert process_message(create_message("/add")) == "Argumet/Arguments are missing"
  end

  test "it_should_not_process_message_when_listener_not_started" do
    assert process_message(create_message("/get")) ==
             "There is no stock listener for you, You should create first"
  end

  test "it_should_return_help_manual" do
    refute process_message(create_message("/help")) == ""
  end

  # todo add test for current instruction

  def start() do
    assert process_message(create_message("/start")) == "Stock listener was created for you"
  end

  def create_message(message), do: %{text: message, from: %{id: 1}}
end
