defmodule Telegram.MessageConsumerTest do
  use ExUnit.Case
  import Bot.MessageConsumer
  alias PortfolioTracker.ServerSupervisor

  @id 1

  setup do
    {:ok, _} = PortfolioTracker.MockExchangeApi.start_link()
    on_exit(fn -> ServerSupervisor.termine_all() end)
  end

  test "it_should_process_create_instruction" do
    assert consume_message(create_message("/create")) == "Portfolio tracker was created for you"
  end

  test "it_should_process_create_instruction_when_tracker_already_created" do
    start()

    assert consume_message(create_message("/create")) ==
             "Your portfolio tracker have already created"
  end

  test "it_should_process_destroy_instruction" do
    start()
    assert consume_message(create_message("/destroy")) == :ok
  end

  test "it_should_process_add_instruction" do
    start()
    assert consume_message(create_message("/add_stock VAKBN VAKIF_BANK 250 4.5")) == :ok
  end

  test "it_should_process_delete_instruction" do
    start()
    assert consume_message(create_message("/delete_stock VAKBN")) == :ok
  end

  # test "it_should_process_live_instruction" do
  #  assert process_message(create_message("/live")) == " "
  # end

  test "it_should_process_get_instruction" do
    start()

    assert consume_message(create_message("/get")) ==
             "Your Portfolio  \nWorth: 0.0 \nUpdate Time:  \nRate: 0.0 🟢 "
  end

  test "it_should_process_add_instruction_when_args_is_invalid" do
    start()

    assert consume_message(create_message("/add_stock VAKBN VAKIF_BANK x x")) ==
             "Argumet/Arguments formats are invalid"
  end

  test "it_should_process_add_instruction_when_args_is_missing" do
    start()
    assert consume_message(create_message("/add_stock")) == "Argumet/Arguments are missing"
  end

  test "it_should_not_process_instruction_when_tracker_not_created" do
    assert consume_message(create_message("/get")) ==
             "There is no portfolio tracker for you, You should create firstly"
  end

  test "it_should_process_help_instruction" do
    refute consume_message(create_message("/help")) == ""
  end

  test "it_should_process_start_instruction" do
    assert consume_message(create_message("/help")) == consume_message(create_message("/start"))
  end

  test "it_should_not_process_when_instruction_not_found" do
    assert consume_message(create_message("not supported instruction")) ==
             "Instruction does not exist"
  end

  test "it_should_only_support_text_instruction" do
    assert consume_message(image_message()) ==
             "Instruction does not exist"
  end

  test "it_should_process_remove_alert_instruction" do
    start()
    assert consume_message(create_message("/set_alert upper_limit TOASO 42.67")) == :ok
    assert consume_message(create_message("/remove_alert TOASO")) == :ok
    assert consume_message(create_message("/get_alerts ")) == "Empty"
  end

  test "it_should_process_set_alert_and_get_alerts" do
    start()
    assert consume_message(create_message("/set_alert upper_limit TOASO 42.67")) == :ok
    assert consume_message(create_message("/get_alerts ")) == "For TOASO upper_limit on 42.67 "
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
    assert consume_message(create_message("/create")) == "Portfolio tracker was created for you"
  end

  def create_message(message), do: %{text: message, from: %{id: @id}}
end
