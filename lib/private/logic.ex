defmodule MultiUserChatServer.Private.Logic do

  def create_user(user_name, %{users: users} = state) do
    new_user = %{
      user_id: state[:id_user] + 1,
      name: user_name,
      sended_messages: [],
      received_messages: [],
      pending_messages: [],
      group: []
    }

    create_usr = Map.put(users, state[:id_user] + 1, new_user)
    {:reply, "user #{state[:id_user] + 1} created", %{state | users: create_usr, id_user: state[:id_user] + 1}}
  end

  def delete_user(user_id, %{users: users} = state) do
    delete_usr = Map.delete(users, user_id)
    {:reply, "user #{user_id} deleted", %{state | users: delete_usr}}
  end

def get_messages(user_id, %{users: users} = state) do
  received_messages =
    Map.get(users, user_id, %{})
    |> Map.get(:received_messages, %{})
    |> Enum.reduce(%{}, fn id, acc ->
      Map.put(acc, id, Map.get(state[:priv_messages], id, %{}))
    end)

  sended_messages =
    Map.get(users, user_id, %{})
    |> Map.get(:sended_messages, %{})
    |> Enum.reduce(%{}, fn id, acc ->
      Map.put(acc, id, Map.get(state[:priv_messages], id, %{}))
    end)

  {:reply, %{Sended_Messages: sended_messages, Received_Messages: received_messages} , state}
end

def get_pending_messages(user_id, %{users: users} = state) do
  received_messages =
    Map.get(users, user_id, %{})
    |> Map.get(:pending_messages, %{})
    |> Enum.reduce(%{}, fn id, acc ->
      Map.put(acc, id, Map.get(state[:priv_messages], id, %{}))
    end)

  {:reply, received_messages, %{state | users: Map.update!(users, user_id, fn user -> Map.put(user, :pending_messages, []) end)}}
end

def get_received_messages(user_id_to, state) do
  messages =
    Map.get(state, :priv_messages, %{})
    |> Enum.filter(fn {_, message} -> message.user_id_to == user_id_to end)
    |> Enum.map(fn {_, message} -> message end)

  {:reply, messages, state}
end

def send_priv_message(user_id_from, user_id_to, content, %{users: users, priv_messages: messages, id_msg: id_msg} = state) do
  new_id_msg = id_msg + 1
  message = %{
    user_id_from: user_id_from,
    user_id_to: user_id_to,
    content: content
  }
  new_messages = Map.put(messages, new_id_msg, message)

  sender = Map.get(users, user_id_from)
  updated_sender = %{sender | sended_messages: sender[:sended_messages] ++ [new_id_msg]}

  receiver = Map.get(users, user_id_to)
  updated_receiver = %{receiver | received_messages: receiver[:received_messages] ++ [new_id_msg], pending_messages: receiver[:pending_messages] ++ [new_id_msg]}

  updated_users = Map.put(users, user_id_from, updated_sender)
  |>Map.put(user_id_to, updated_receiver)

  new_state = %{state | priv_messages: new_messages, id_msg: new_id_msg, users: updated_users}
  {:reply, message, new_state}
end

def alter_name(user_id, new_user_name, state) do
  new_user =
    Map.update!(state[:users], user_id, fn user ->
      Map.put(user, :name, new_user_name)
    end)

  {:reply, "user #{user_id} name changed to #{new_user_name}", %{state | users: new_user}}
end

end
