defmodule MyAppBe.Live.ShopLive.OrderitemFieldComponent do
  @moduledoc false
  use KandisOrderUiWeb, :live_component

  @impl true
  def update(assigns, socket) do
    stored_value = assigns.data[assigns.field.name]

    input_options =
      assigns.field[:input_options]
      |> MavuUtils.if_nil([])
      |> Keyword.put(
        :value,
        get_input_value_for_field(assigns.f, assigns.field.name, stored_value)
      )

    socket =
      socket
      |> assign(assigns)
      |> assign(
        stored_value: stored_value,
        display_value: assigns[:display_value] || stored_value |> display_value(assigns.field),
        input_options: input_options,
        is_editable: is_editable?(assigns.field) && assigns.editable
      )

    {:ok, socket}
  end

  def get_input_value_for_field(form, field_name, stored_value) do
    case form.source.changes[field_name] do
      nil -> stored_value
      val -> val
    end
  end

  def display_value(value, %{input_options: input_options}) do
    case input_options[:using] do
      :textarea -> Phoenix.HTML.Format.text_to_html(value || "")
      _type -> value
    end
  end

  def display_value(value, _), do: value

  def is_editable?(field), do: field[:readonly] !== true
end
