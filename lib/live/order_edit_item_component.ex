defmodule MyAppBe.Live.ShopLive.OrderEditItemComponent do
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
    |> validate_decimal(:single_price)
    |> validate_decimal(:taxrate)

    # |> Ecto.Changeset.update_change(:tags, &String.upcase/1)
  end

  def validate_decimal(changeset, field, options \\ []) do
    Ecto.Changeset.validate_change(changeset, field, fn
      _, "" ->
        []

      _, str ->
        Kandis.KdHelpers.is_parsable_to_dec?(str)
        |> case do
          true -> []
          false -> [{field, options[:message] || "not a decimal number."}]
        end
    end)
  end

  def fieldconf do
    [
      %{name: :title},
      %{name: :subtitle},
      %{name: :single_price},
      %{name: :amount, type: :integer, input_options: [using: :number_input, min: 1, max: 999]},
      %{name: :total_price},
      %{name: :taxrate},
      %{name: :deleted, type: :boolean}
    ]
  end

  def get_field(name) when is_atom(name) do
    fieldconf()
    |> Enum.find(&(&1.name == name))
  end

  def current_value(%Phoenix.HTML.Form{} = form, data, field_name)
      when is_map(data) and is_atom(field_name) do
    current_value(form.source, data, field_name)
  end

  def current_value(%Ecto.Changeset{} = changeset, data, field_name)
      when is_map(data) and is_atom(field_name) do
    case {changeset.changes[field_name], changeset.errors[field_name]} do
      {val, nil} when val != nil -> val
      _ -> data[field_name]
    end
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
      changeset:
        Ecto.Changeset.delete_change(socket.assigns.changeset, fieldname)
        |> Ecto.Changeset.delete_change(:total_price)
    )
  end

  def set_editing(socket, fieldname, var) when is_binary(fieldname),
    do: set_editing(socket, String.to_existing_atom(fieldname), var)

  @impl true
  def handle_event("start_edit", %{"fieldname" => fieldname}, socket) do
    {:noreply, socket |> set_editing(fieldname, true)}
  end

  @impl true
  def handle_event("cancel_edit", %{"fieldname" => fieldname}, socket) do
    {:noreply, socket |> set_editing(fieldname, false) |> notify_parent()}
  end

  def handle_event("validate", msg, socket = %{assigns: %{data: data}}) do
    fdata = msg["fdata"] || %{}

    changeset =
      changeset(fdata, socket.assigns.fields)
      |> Map.put(:action, :insert)

    changeset =
      if !is_nil(changeset.changes[:single_price]) || !is_nil(changeset.changes[:amount]) do
        changeset
        |> Ecto.Changeset.put_change(
          :total_price,
          Decimal.mult(
            current_value(changeset, data, :single_price) |> Kandis.KdHelpers.to_dec(),
            current_value(changeset, data, :amount) |> Kandis.KdHelpers.to_dec()
          )
          |> to_string()
        )
      else
        changeset |> Ecto.Changeset.delete_change(:total_price)
      end

    socket =
      socket
      |> assign(changeset: changeset)
      |> notify_parent()

    {:noreply, socket}
  end

  def handle_event("undelete_item", _msg, socket) do
    new_changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.delete_change(:deleted)

    socket =
      socket
      |> assign(changeset: new_changeset)
      |> notify_parent()

    {:noreply, socket}
  end

  def handle_event("delete_item", _msg, socket) do
    new_changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:deleted, true)

    socket =
      socket
      |> assign(changeset: new_changeset)
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
