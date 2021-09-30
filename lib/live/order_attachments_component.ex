defmodule KandisOrderUi.Live.OrderAttachmentsComponent do
  @moduledoc false
  use KandisOrderUiWeb, :live_component

  @impl true

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(versions: get_versions(assigns.order))

    {:ok, socket}
  end

  def get_versions(order) when is_map(order) do
    files = Kandis.Pdfgenerator.get_all_files_for_order_nr(order.order_nr)

    Kandis.Order.get_history_list(order)
    |> Enum.filter(&(&1[:_version] != nil))
    |> Enum.map(&augment_history_line_with_files(&1, files))
  end

  def augment_history_line_with_files(line, files) when is_map(line) and is_list(files) do
    line
    |> Map.put(:files, get_files_for_version(files, line[:_version]))
  end

  def get_files_for_version(files, version) when is_list(files) and is_integer(version) do
    files
    |> Enum.filter(fn a -> a.version == version end)
    |> Enum.map(fn a -> {a.mode, a} end)
    |> Map.new()
  end

  def get_files_for_version(_, _), do: %{}

  @impl true
  def handle_event("create_orderfile", %{"mode" => mode}, socket) do
    # Kandis.Pdfgenerator.generate_order_pdf(mode, socket.assigns.order.order_nr)

    Kandis.Order.get_order_file(socket.assigns.order.order_nr, mode, %{})

    {:noreply, socket |> assign(versions: get_versions(socket.assigns.order))}
  end
end
