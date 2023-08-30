defmodule MultiUserChatServer do
  use GenServer
  alias MultiUserChatServer.Private.Logic, as: PrivLogic
  alias MultiUserChatServer.Groups.Logic, as: GroupLogic

  def start_link(), do: GenServer.start_link(__MODULE__, %{groups: %{}, users: %{}, priv_messages: %{}, group_messages: %{}, id_msg: 0, id_group: 0, id_user: 0}, name: __MODULE__)

  def init(state), do: {:ok, state}

  def handle_call({:create_user, user_name}, _from, state), do: PrivLogic.create_user(user_name, state)

  def handle_call({:get_all}, _from, state), do: {:reply, state, state}

  def handle_call({:create_group, user_id, group_name}, _from, state), do: GroupLogic.create_group(user_id, group_name, state)

  def handle_call({:delete_user, user_id}, _from, state), do: PrivLogic.delete_user(user_id, state)

  def handle_call({:get_user}, _from, state), do: {:reply, Map.get(state, :users, %{}), state}

  def handle_call({:get_user, user_id}, _from, state), do: {:reply, Map.get(state[:users], user_id, %{}) , state}

  def handle_call({:get_group}, _from, state), do: {:reply, Map.get(state, :groups, %{}), state}

  def handle_call({:get_group, group_id}, _from, state), do: {:reply, Map.get(state[:groups], group_id, %{}), state}

  def handle_call({:get_messages}, _from, state), do: {:reply, %{"Private_Messages" => Map.get(state, :priv_messages, %{}), "Group_messages" => Map.get(state, :group_messages, %{})}, state}

  def handle_call({:get_messages, user_id}, _from, state), do: PrivLogic.get_messages(user_id, state)

  def handle_call({:get_pending_messages, user_id}, _from, state), do: PrivLogic.get_pending_messages(user_id, state)

  def handle_call({:get_received_messages, user_id}, _from, state), do: PrivLogic.get_received_messages(user_id, state)

  def handle_call({:get_group_messages, user_id, group_id}, _from, state), do: GroupLogic.get_group_messages(user_id, group_id, state)

  def handle_call({:get_group_messages}, _from, state), do: {:reply, Map.get(state, :group_messages, %{}), state}

  def handle_call({:send_priv_message, user_id_from, user_id_to, content}, _from, state), do: PrivLogic.send_priv_message(user_id_from, user_id_to, content, state)

  def handle_call({:send_group_message, user_id, group_id, content}, _from, state), do: GroupLogic.send_group_message(user_id, group_id, content, state)

  def handle_call({:alter_name, user_id, new_user_name}, _from, state), do: PrivLogic.alter_name(user_id, new_user_name, state)

  def create_user(user_name) do
    GenServer.call(__MODULE__, {:create_user, user_name})
  end

  def create_group(user_id, group_name) do
    GenServer.call(__MODULE__, {:create_group, user_id, group_name})
  end

  def delete_user(user_id) do
    GenServer.call(__MODULE__, {:delete_user, user_id})
  end

  def get_user() do
    GenServer.call(__MODULE__, {:get_user})
  end

  def get_pending_messages(user_id) do
    GenServer.call(__MODULE__, {:get_pending_messages, user_id})
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

  def get_group() do
    GenServer.call(__MODULE__, {:get_group})
  end

  def get_all() do
    GenServer.call(__MODULE__, {:get_all})
  end

  def get_group(group_id) do
    GenServer.call(__MODULE__, {:get_group, group_id})
  end

  def send_priv_message(user_id_from, user_id_to, content) do
    GenServer.call(__MODULE__, {:send_priv_message, user_id_from, user_id_to, content})
  end

  def send_group_message(user_id, group_id, content) do
    GenServer.call(__MODULE__, {:send_group_message, user_id, group_id, content})
  end

  def get_received(user_id_to) do
    GenServer.call(__MODULE__, {:get_received_messages, user_id_to})
  end

  def get_group_messages(user_id, group_id) do
    GenServer.call(__MODULE__, {:get_group_messages, user_id, group_id})
  end

  def get_group_messages() do
    GenServer.call(__MODULE__, {:get_group_messages})
  end

  def alter_name(user_id, new_user_name) do
    GenServer.call(__MODULE__, {:alter_name, user_id, new_user_name})
  end

end
