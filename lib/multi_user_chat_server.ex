defmodule MultiUserChatServer do
  use GenServer

  def start_link(), do: GenServer.start_link(__MODULE__, initial(), name: __MODULE__)

  def initial(), do: %{users: %{}, messages: %{}, id_msg: 0}
  # def initial(), do: %{users: %{}, messages: %{}, rooms: %{}}

  def init(state), do: {:ok, state}

  def handle_call({:new_user, user_id, user_name}, _from, %{users: users} = state) do
    new_user = %{
      user_id: user_id,
      name: user_name,
      messages: []
    }

    create_usr = Map.put(users, user_id, new_user)
    {:reply, "user #{user_id} created", %{state | users: create_usr}}
  end

  def handle_call({:remove_user, user_id}, _from, state) do
    updated_users =
      Map.update!(state, :users, fn old_users ->
        Map.delete(old_users, user_id)
      end)

    new_state = Map.put(state, :users, updated_users)

    {:reply, "user #{user_id} deleted", new_state}
  end

  def handle_call({:get_user}, _from, state), do: {:reply, Map.get(state, :users, %{}), state}

  def handle_call({:get_user, user_id}, _from, state) do
    user = Map.get(state[:users], user_id, %{})
    {:reply, user, state}
  end

  def handle_call({:get_messages}, _from, state),
    do: {:reply, Map.get(state, :messages, %{}), state}

  def handle_call({:get_messages, user_id}, _from, state) do
    messages =
      Map.get(state, :users, %{})
      |> Map.get(user_id, %{})
      |> Map.get(:messages, %{})

    {:reply, messages, state}
  end

  def handle_call({:get_received_messages, user_id_to}, _from, state) do
    messages =
      Map.get(state, :messages, %{})
      |> Enum.filter(fn {_, message} -> message.user_id_to == user_id_to end)
      |> Enum.map(fn {_, message} -> message end)

    {:reply, messages, state}
  end

  def handle_call(
        {:send_message, user_id_from, user_id_to, content},
        _from,
        %{users: users, messages: messages, id_msg: id_msg} = state
      ) do
    message = %{
      user_id_from: user_id_from,
      user_id_to: user_id_to,
      content: content
    }

    new_messages = Map.put(messages, id_msg + 1, message)

    sender = Map.get(users, user_id_from)
    updated_sender = %{sender | messages: sender[:messages] ++ [content]}

    updated_users = Map.put(users, user_id_from, updated_sender)

    new_state = %{state | messages: new_messages, id_msg: id_msg + 1, users: updated_users}

    {:reply, message, new_state}
  end

  def handle_call({:alter_name, user_id, new_user_name}, _from, state) do
    Map.get(state, :users, %{})
    |> Map.get(user_id, %{})
    |> Map.put(:name, new_user_name)

    {:reply, "user #{user_id} name changed to #{new_user_name}", state}
  end

  def create_user(user_id, user_name) do
    GenServer.call(__MODULE__, {:new_user, user_id, user_name})
  end

  def delete_user(user_id) do
    GenServer.call(__MODULE__, {:remove_user, user_id})
  end

  def get_user() do
    GenServer.call(__MODULE__, {:get_user})
  end

  def get_user(user_id) do
    GenServer.call(__MODULE__, {:get_user, user_id})
  end

  def get_messages() do
    GenServer.call(__MODULE__, {:get_messages})
  end

  def get_messages(user_id) do
    GenServer.call(__MODULE__, {:get_messages, user_id})
  end

  def send_message(user_id_from, user_id_to, content) do
    GenServer.call(__MODULE__, {:send_message, user_id_from, user_id_to, content})
  end

  def get_received(user_id_to) do
    GenServer.call(__MODULE__, {:get_received_messages, user_id_to})
  end
end

## estrutura das messages:
# %{
#  user_id_from: "user_id",
#  user_id_to: "user_id",
#  content: "content",
# }

## estrutura dos users:
# %{
#  user_id: "user_id",
#  name: "name",
#  messages: [content, content, content]
# }
