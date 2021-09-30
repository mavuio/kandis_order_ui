defmodule KandisOrderUi.Live.OrderEditOrderitemsComponent do
  @moduledoc false
  use KandisOrderUiWeb, :live_component

  @impl true

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(items: assigns.data.lineitems)

    {:ok, socket}
  end
end
