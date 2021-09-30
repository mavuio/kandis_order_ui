defmodule KandisOrderUi.Live.OrderListComponent do
  @moduledoc false

  use KandisOrderUiWeb, :live_component

  require Ecto.Query

  @impl true
  def update(assigns = %{context: context}, socket) do
    orders = Kandis.Order.get_order_query(context.params)
    id = "order_list"

    socket =
      socket
      |> assign(assigns)
      |> assign(
        lang: context.lang,
        id: id,
        items_query: orders,
        items_filtered: MavuList.process_list(orders, id, listconf()),
        latest_invoice_nr:
          Kandis.Order.get_latest_invoice_nr(Kandis.Order.get_invoice_nr_prefix(:live))
      )

    {:ok, socket}
  end

  def listconf() do
    %{
      # https://hexdocs.pm/ecto/Ecto.Schema.html#module-types-and-casting
      columns: [
        %{name: :id, label: "ID"},
        %{name: :order_nr, label: "Order-Nr."},
        %{name: :state, label: "state"},
        %{name: :inserted_at, label: "created", type: :datetime},
        %{name: :email, label: "email"},
        %{name: :tags, label: "tags"},
        %{name: :total, path: [:total_price], label: "total", type: :price},
        # %{name: :delivery_type, label: "delivery_type"},
        %{name: :invoice_nr, label: "RG-Nr"}
        # %{name: :cart_id, label: "cart_id", type: :uuid, user_sortable: false},
        # %{name: :vid, path: [:ordervars, "vid"], label: "vid", type: :uuid}
      ],
      repo: MyApp.Repo,
      filter: &listfilter/3
    }
  end

  def listfilter(source, conf, tweaks) do
    keyword = tweaks[:keyword]

    if MavuUtils.present?(keyword) do
      kwlike = "%#{keyword}%"

      source
      |> Ecto.Query.where(
        [o],
        like(o.order_nr, ^kwlike) or like(o.email, ^kwlike) or like(o.tags, ^kwlike) or
          like(o.invoice_nr, ^kwlike)
      )
    else
      source
    end
  end

  @impl true
  def handle_event("list." <> event, msg, socket) do
    {:noreply,
     assign(socket,
       items_filtered:
         MavuList.handle_event(
           event,
           msg,
           socket.assigns.items_query,
           socket.assigns.items_filtered
         )
     )}
  end

  @impl true
  def handle_event("delete_latest_invoice", %{"invoice-nr" => invoice_nr}, socket) do
    socket =
      case Kandis.Order.delete_latest_invoice(invoice_nr) do
        {:ok, invoice_nr, order} ->
          put_flash(
            socket,
            :info,
            "invoice #{invoice_nr} for order #{order.order_nr} was deleted !"
          )

        {:error, msg, _data} ->
          put_flash(socket, :error, msg)
      end

    {:noreply,
     assign(socket,
       items_filtered:
         MavuList.handle_event(
           "reprocess",
           nil,
           socket.assigns.items_query,
           socket.assigns.items_filtered
         ),
       latest_invoice_nr:
         Kandis.Order.get_latest_invoice_nr(Kandis.Order.get_invoice_nr_prefix(:live))
     )}
  end
end
