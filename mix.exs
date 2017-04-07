defmodule SigawsQuickstartProvider.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @description """
  Signature verification provider implementation for Sigaws. This quickstart
  provider implementation can be used to try out AWS signature verification
  using `plug_sigaws` Hex package.
  """
  @source_url "https://github.com/handnot2/sigaws_quickstart_provider"
  @blog_url "https://handnot2.github.io/blog/elixir/aws-signature-aws"

  def project do
    [app: :sigaws_quickstart_provider,
     version: @version,
     description: @description,
     package: package(),
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:sigaws, "~> 0.1"}
    ]
  end

  defp package do
    [
      maintainers: ["handnot2"],
      files: ["config", "lib", "LICENSE", "mix.exs", "README.md"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Blog" => @blog_url
      }
    ]
  end
end
