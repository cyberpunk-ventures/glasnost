defmodule Glasnost.Web.GolosEventsChannel do
  use Phoenix.Channel

  def join("channel:golos_events", _message, socket) do
    {:ok, socket}
  end

  def join("channel:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

end
