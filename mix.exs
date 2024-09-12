defmodule ExFCM.Mixfile do
  use Mix.Project

  def project do
    [app: :exfcm,
     version: "0.1.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      mod: {ExFCM.Application, []},
      applications: [:logger],
      extra_applications: [:tesla,:goth]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:tesla, "~> 1.9"},
      {:goth, "~> 1.2"},
      {:finch, "~> 0.13", optional: true},


      {:httpoison, "~> 0.9.0"}, # deprecated
      {:poison, ">= 0.0.0"}, # deprecated
      {:ex_doc, ">= 0.0.0", only: :dev} 
    ]
  end

  defp description do
    """
    Simple wrapper around Firebase Cloud Messaging that uses HTTPoison.
    """
  end

  defp package do
    [# These are the default files included in the package
     name: :exfcm,
     files: ["lib", "mix.exs"],
     maintainers: ["Jakub Hajto", "Keith Brings"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/Hajto/ExFCM"}]
  end
end
