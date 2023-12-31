defmodule WaveWeb.ChatLive do
  use WaveWeb, :live_view

  import WaveWeb.MessageComponent
  alias Wave.Chats
  alias Wave.Chats.Helpers

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    rooms = Chats.list_rooms()

    socket =
      socket
      |> assign(rooms: rooms)
      |> assign(non_empty_state?: false)
      |> assign(current_user: current_user)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"name" => name}, _uri, socket) do
    room = Chats.get_room!(name)

    changeset =
      Chats.change_message(%{
        room_id: room.id,
        user_id: socket.assigns.current_user.id,
        data: ""
      })

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Wave.PubSub, "new_message#{room.id}")
    end

    room_form = Chats.change_room() |> to_form()

    socket =
      socket
      |> assign(changeset: changeset)
      |> assign(page_title: room.name)
      |> assign(room_form: room_form)
      |> assign(room: room)
      |> assign(page: 1, per_page: 10)
      |> paginate_messages(1)
      |> assign(end_of_timeline?: false)
      |> assign(:ip, get_ip())

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"message" => _params}, socket) do
    # IO.inspect(params)
    {:noreply, socket}
  end

  @impl true
  def handle_event("change", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("create-room", %{"room" => room_params}, socket) do
    case Chats.create_room(room_params) do
      {:ok, room} ->
        {:noreply, push_navigate(socket, to: ~p"/chat/#{room}")}

      {:error, changeset} ->
        IO.inspect(changeset)
        {:noreply, assign(socket, room_form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("switch-room", %{"room" => room_name}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/chat/#{room_name}")}
  end

  @impl true
  def handle_event("create", %{"message" => params}, socket) do
    html = Helpers.to_html!(params["data"]) |> Helpers.santize_message()

    params =
      params
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.put("room_id", socket.assigns.room.id)
      |> Map.put("data", html)

    case Chats.create_message(params) do
      {:ok, _message} ->
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # Code snippets from LiveView Docs

  def handle_event("next-page", _, socket) do
    {:noreply, paginate_messages(socket, socket.assigns.page + 1)}
  end

  def handle_event("prev-page", %{"_overran" => true}, socket) do
    {:noreply, paginate_messages(socket, 1)}
  end

  def handle_event("prev-page", _, socket) do
    if socket.assigns.page > 1 do
      {:noreply, paginate_messages(socket, socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  defp paginate_messages(socket, new_page) when new_page >= 1 do
    %{per_page: per_page, page: cur_page} = socket.assigns

    messages =
      Chats.list_messages(socket.assigns.room.id,
        offset: (new_page - 1) * per_page,
        limit: per_page
      )

    socket =
      if new_page > cur_page do
        stream(socket, :messages, messages, at: 0, limit: 1000)
      else
        stream(socket, :messages, Enum.reverse(messages), at: 0, limit: 1000)
      end

    case messages do
      [] ->
        assign(socket, end_of_timeline?: true)

      [_ | _] ->
        socket
        |> assign(end_of_timeline?: false)
        |> assign(:page, new_page)
    end
  end

  @impl true
  def handle_info({:new_message, new_message}, socket) do
    socket = stream_insert(socket, :messages, new_message, at: -1)

    {:noreply, socket}
  end

  defp get_ip do
    %{"origin" => ip} = Req.get!("https://httpbin.org/ip").body
    ip
  end
end
