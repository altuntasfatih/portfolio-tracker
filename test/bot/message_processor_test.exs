defmodule Telegram.MessageProcessorTest do
  use ExUnit.Case
  import Bot.MessageProcessor
  alias StockListener.MySupervisor

  setup do
    on_exit(fn -> MySupervisor.termine_all() end)
  end


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

  test "it_should_delete_stock" do
    start()
    assert process_message(create_message("/delete VAKBN")) == :ok
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

  test "it_should_return_not_support" do
    assert process_message(create_message("not supported message")) ==
             "Instruction does not exist"
  end

  test "it_should_only_support_text_message" do
    assert process_message(image_message()) ==
             "Instruction does not exist"
  end

  def image_message() do
    %{
      audio: nil,
      caption: nil,
      channel_chat_created: nil,
      chat: %{
        first_name: "Fatih",
        id: 124_101_565,
        last_name: nil,
        photo: nil,
        title: nil,
        type: "private",
        username: nil
      },
      contact: nil,
      date: 1_614_186_146,
      delete_chat_photo: nil,
      document: nil,
      edit_date: nil,
      entities: nil,
      forward_date: nil,
      forward_from: nil,
      forward_from_chat: nil,
      from: %{
        first_name: "Fatih",
        id: 124_101_565,
        last_name: nil,
        username: nil
      },
      group_chat_created: nil,
      left_chat_member: nil,
      location: nil,
      message_id: 317,
      migrate_from_chat_id: nil,
      migrate_to_chat_id: nil,
      new_chat_member: nil,
      new_chat_photo: [],
      new_chat_title: nil,
      photo: [
        %{
          file_id:
            "AgACAgQAAxkBAAIBPWA2hqJcFWbtqrd94qcgdR1EJpfaAAKbtjEbv46xUQ5gpcO-8PEOjob5KF0AAwEAAwIAA3kAA1ITBAABHgQ",
          file_size: 120_613,
          height: 1280,
          width: 804
        }
      ],
      pinned_message: nil,
      reply_to_message: nil,
      sticker: nil,
      supergroup_chat_created: nil,
      text: nil,
      venue: nil,
      video: nil,
      voice: nil
    }
  end

  def start() do
    assert process_message(create_message("/start")) == "Stock listener was created for you"
  end

  def create_message(message), do: %{text: message, from: %{id: 1}}
end
