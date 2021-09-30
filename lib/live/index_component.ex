defmodule KandisOrderUi.Live.IndexComponent do
  @moduledoc false
  use KandisOrderUiWeb, :live_component

  # import KandisOrderUi, only: [get_conf_val: 2]
  require Ecto.Query

  # def snippet_groups_module(assigns),
  #   do: assigns[:context][:order_ui_conf][:snippet_groups_module]

  @impl true
  def update(%{context: context} = assigns, socket) do
    # first load
    {:ok,
     socket
     |> assign(assigns)
     |> assign(smart_base_path: smart_base_path(assigns.base_path, context))}
  end

  def smart_base_path(base_path_func, context) when is_map(context) do
    fn params ->
      {context.params, params}

      (context.params || %{})
      # keep this params in URL:
      |> Map.take(~w(langs rec return_to))
      |> Map.merge(params || %{})
      |> case do
        %{"rec" => "0"} = params -> Map.drop(params, ~w(rec))
        params -> params
      end
      |> base_path_func.()
    end
  end
end
