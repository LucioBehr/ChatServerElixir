defmodule MultiUserChatServerTest do
  use ExUnit.Case
  doctest MultiUserChatServer

  alias MultiUserChatServer, as: ChatServer

  setup do
    {:ok, _pid} = ChatServer.start_link()
    :ok
  end

  test "should add a new user" do
    response = ChatServer.create_user("user1", "User One")
    assert response == "user user1 created"
  end

  test "should send a new message" do
    ChatServer.create_user(1, "User One")
    ChatServer.create_user(2, "User Two")
    response = ChatServer.send_message(1, 2, "Hello User Two")
    assert response == %{content: "Hello User Two", user_id_from: 1, user_id_to: 2}
  end

  test "should delete a user" do
    ChatServer.create_user(1, "User One")
    response = ChatServer.delete_user(1)
    assert response == "user 1 deleted"
  end

  test "should read all received messages" do
    ChatServer.create_user(1, "User One")
    ChatServer.create_user(2, "User Two")

    response = [
      ChatServer.send_message(1, 2, "Hello User Two0"),
      ChatServer.send_message(1, 2, "Hello User Two1"),
      ChatServer.send_message(1, 2, "Hello User Two2")
    ]

    assert response == [
             %{content: "Hello User Two0", user_id_from: 1, user_id_to: 2},
             %{content: "Hello User Two1", user_id_from: 1, user_id_to: 2},
             %{content: "Hello User Two2", user_id_from: 1, user_id_to: 2}
           ]
  end
end
