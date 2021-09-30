defmodule KandisOrderUi.Live.OrderEditComponent do
  @moduledoc false

  use KandisOrderUiWeb, :live_component

  alias Kandis.Order

  @impl true

  def update(%{kandis_order_ui_msg: :ignore}, socket) do
    "ignore" |> IO.inspect(label: "mwuits-debug 2021-06-20_22:19 ❖ ")
    {:ok, socket}
  end

  def update(%{kandis_order_ui_msg: msg}, socket) when not is_nil(msg) do
    # msg |> IO.inspect(label: "mwuits-debug 2021-06-20_22:19 ❖ ")
    msg |> IO.inspect(label: "mwuits-debug 2021-06-20_13:23 received pass-down msg")
    res = handle_root_msg(msg, socket)
    send(self(), {:kandis_order_ui_msg, :ignore})
    res
  end

  def update(assigns = %{context: context}, socket) do
    order = Order.get_by_order_nr(context.params["order_nr"])
    orderhtml = Order.get_orderhtml(order)

    socket =
      socket
      |> assign(assigns)
      |> assign(
        order: order,
        id: "order_edit",
        orderhtml: orderhtml,
        changed_data: %{},
        changed_data_errors: %{},
        version: 1
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    version = socket.assigns.version + 1

    send_update(KandisOrderUi.Live.OrderEditOrdervarsComponent,
      id: "edit_ordervars",
      data: socket.assigns.order.ordervars,
      data_key: :ordervars,
      version: version
    )

    send_update(KandisOrderUi.Live.OrderEditOrderitemsComponent,
      id: "edit_orderitems",
      data: socket.assigns.order.orderitems,
      data_key: :orderitems,
      version: version
    )

    {:noreply,
     socket
     |> assign(changed_data: %{}, changed_data_errors: %{}, version: version)}
  end

  @impl true
  def handle_event("save", _, socket) do
    {:ok, order} =
      Kandis.Order.update_ordervars(
        socket.assigns.order.order_nr,
        socket.assigns.changed_data[:ordervars]
      )

    {:ok, order} =
      Kandis.Order.update_orderitems(
        socket.assigns.order.order_nr,
        socket.assigns.changed_data |> Map.drop([:ordervars])
      )

    socket =
      socket
      |> put_flash(:info, "changes saved")
      |> assign(changed_data: %{}, changed_data_errors: %{})
      |> assign(order: order)

    {:noreply, socket}
  end

  def handle_root_msg(
        {:data_changed, data_key, %{changes: changes, errors: errors}} = _msg,
        socket
      ) do
    {:ok,
     socket
     |> assign(
       [
         changed_data: put_in(socket.assigns.changed_data, [data_key], changes),
         changed_data_errors: put_in(socket.assigns.changed_data_errors, [data_key], errors)
       ]
       |> IO.inspect(label: "mwuits-debug 2021-10-01_00:01 POX")
     )}
  end

  def pending_changes?(changed_data) do
    changed_data
    |> Map.to_list()
    |> Enum.flat_map(fn {_key, val} -> val end)
    |> MavuUtils.present?()
  end

  def pending_errors?(changed_data_errors) do
    changed_data_errors
    |> Map.to_list()
    |> Enum.flat_map(fn {_key, val} -> val end)
    |> MavuUtils.present?()
  end
end
