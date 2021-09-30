defmodule KandisOrderUi.Live.ShopLive.AlpineTestComponent do
  @moduledoc false
  use KandisOrderUiWeb, :live_component

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(open: false)

    {:ok, socket}
  end

  def handle_event("toggle", _, socket) do
    {:noreply, socket |> assign(open: !socket.assigns.open)}
  end
end
