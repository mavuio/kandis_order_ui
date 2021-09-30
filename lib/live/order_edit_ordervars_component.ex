defmodule KandisOrderUi.Live.OrderEditOrdervarsComponent do
  @moduledoc false
  use KandisOrderUiWeb, :live_component

  @impl true

  def update(assigns, socket) do
    fields = fieldconf()

    socket =
      socket
      |> assign(assigns)
      |> assign(
        fields: fields,
        changeset: changeset(%{}, fields),
        editing: %{}
      )

    {:ok, socket}
  end

  def changeset(values, fields) do
    data = %{}

    types = create_types_from_fieldconf(fields)

    {data, types}
    |> Ecto.Changeset.cast(values, Map.keys(types))

    # |> Ecto.Changeset.update_change(:tags, &String.upcase/1)
  end

  def fieldconf do
    [
      %{name: :ordertype, label: "Ordertype", readonly: true},
      # %{name: :dealer_id, label: "Dealer Id", type: :integer},
      %{name: :email, label: "Email", input_options: [using: :email_input]},
      # %{name: :dealer_title, label: "Dealer Title"},
      %{name: :company, label: "Company"},
      %{name: :first_name, label: "First Name"},
      %{name: :last_name, label: "Last Name"},
      %{name: :street, label: "Street"},
      %{name: :city, label: "City"},
      %{name: :zip, label: "Zip"},
      %{name: :delivery_type, label: "Delivery Type", readonly: true},
      %{name: :payment_type, label: "Payment Type", readonly: true},
      %{name: :merchant_notes, label: "Notes", input_options: [using: :textarea]},
      %{name: :tags, label: "Tags"}
      # %{name: :pickup, label: "Pickup", input_options: [using: :select, items: ~w(yes no)]}
    ]
  end

  def create_types_from_fieldconf(fields) when is_list(fields) do
    fields
    |> Enum.map(fn field -> {field.name, get_type_from_field(field)} end)
    |> Map.new()
  end

  def get_type_from_field(%{type: type}) when is_atom(type), do: type

  def get_type_from_field(_field), do: MavuUtils.TrimmedString

  def set_editing(socket, fieldname, true) when is_atom(fieldname),
    do: socket |> assign(editing: Map.put(socket.assigns.editing, fieldname, true))

  def set_editing(socket, fieldname, false) when is_atom(fieldname) do
    socket
    |> assign(
      editing: Map.delete(socket.assigns.editing, fieldname),
      changeset: Ecto.Changeset.delete_change(socket.assigns.changeset, fieldname)
    )
  end

  def set_editing(socket, fieldname, var) when is_binary(fieldname),
    do: set_editing(socket, String.to_existing_atom(fieldname), var)

  @impl true
  def handle_event("start_edit", %{"fieldname" => fieldname}, socket),
    do: {:noreply, socket |> set_editing(fieldname, true)}

  @impl true
  def handle_event("cancel_edit", %{"fieldname" => fieldname}, socket) do
    "cancel edit #{fieldname}" |> MavuUtils.log("mwuits-debug 2021-03-02_10:44 ", :info)
    {:noreply, socket |> set_editing(fieldname, false) |> notify_parent()}
  end

  def handle_event("validate", msg, socket) do
    changeset =
      changeset(msg["fdata"] || %{}, socket.assigns.fields)
      |> Map.put(:action, :insert)

    socket =
      socket
      |> assign(changeset: changeset)
      |> notify_parent()

    {:noreply, socket}
  end

  def notify_parent(socket) do
    # socket.assigns.changeset |>IO.inspect(label: "mwuits-debug 2021-03-02_10:33 NOTOIFY")
    send(
      self(),
      {:kandis_order_ui_msg,
       {:data_changed, socket.assigns.data_key,
        Map.take(socket.assigns.changeset, [:changes, :errors])}}
    )

    socket
  end
end
