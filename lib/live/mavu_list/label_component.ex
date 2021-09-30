defmodule KandisOrderUi.Live.MavuList.LabelComponent do
  @moduledoc false
  use KandisOrderUiWeb, :live_component

  @impl true
  def update(%{list: list, name: name} = _assigns, socket) do
    socket =
      socket
      |> assign(MavuList.generate_assigns_for_label_component(list, name))

    {:ok, socket}
  end
end
