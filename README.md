# SigawsQuickstartProvider

This is an implementation of `Sigaws.Provider` behavior that can be used
along with `plug_sigaws` Hex package to enable AWS signature authentication
for REST API endpoints.

## Installation

This package can be installed by adding `sigaws_quickstart_provider` to your
list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:sigaws_quickstart_provider, "~> 0.1.0"}]
end
```

Check out this
[Blog post](https://handnot2.github.io/blog/elixir/aws-signature-sigaws).
