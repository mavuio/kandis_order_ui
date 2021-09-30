defmodule KandisOrderUi.MixProject do
  use Mix.Project

  @version "0.1.12"
  def project do
    [
      app: :kandis_order_ui,
      version: @version,
      elixir: "~> 1.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "KandisOrderUi",
      source_url: "https://github.com/mavuio/kandis_order_ui"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}

      {:phoenix_html, ">= 3.0.0"},
      {:phoenix, ">= 1.6.0"},
      {:phoenix_live_view, ">= 0.16.0"},
      {:mavu_utils, "~> 0.1.0"},
      {:mavu_list, "~> 0.1.9"},
      {:mavu_form, "~> 0.1.3"},
      # {:kandis, ">= 0.0.0"},
      {:pit, "~> 1.2.0"},
      {:heroicons, "~> 0.1.0"},
      {:ecto, ">= 3.0.0"},
      {:jason, ">= 1.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "KandisOrderUi: Rodent - Management for mavu_* projects"
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/mavuio/kandis_order_ui"}
    ]
  end
end
