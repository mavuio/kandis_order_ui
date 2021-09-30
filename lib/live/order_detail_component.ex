defmodule KandisOrderUi.Live.OrderDetailComponent do
  @moduledoc false

  use KandisOrderUiWeb, :live_component

  alias Kandis.Order

  @impl true

  def update(assigns = %{context: context}, socket) do
    orders = Kandis.Order.get_order_query(context.params)
    id = "order_list"

    order = Order.get_by_order_nr(context.params["order_nr"])
    orderhtml = Order.get_orderhtml(order)

    socket =
      socket
      |> assign(assigns)
      |> assign(
        order: order,
        orderhtml: orderhtml
      )

    {:ok, socket}
  end

  def handle_event("cancel_order", msg, socket) do
    new_order = Order.set_state(socket.assigns.order.id, "cancelled")

    socket =
      if(new_order.state == "cancelled") do
        socket
        |> assign(
          order: new_order,
          orderhtml: Order.get_orderhtml(new_order)
        )
        |> put_flash(:info, "order was cancelled")
      else
        socket
        |> put_flash(:error, "order was NOT cancelled !")
      end

    {:noreply, socket}
  end

  def handle_event("restore_version", %{"version" => version}, socket) do
    version = version |> MavuUtils.to_int()

    socket =
      case Order.restore_archive_version(socket.assigns.order.order_nr, version) do
        {:ok, updated_order} ->
          socket
          |> assign(
            order: updated_order,
            orderhtml: Order.get_orderhtml(updated_order)
          )
          |> put_flash(:info, "order-version was restored")

        _ ->
          socket
          |> put_flash(:error, "order-version was NOT restored !")
      end

    {:noreply, socket}
  end
end
