defmodule SigawsQuickstartProvider do
  @moduledoc """
  A quick start `Sigaws` verification provider that implements `Sigaws.Provider` behavior.

  (Refer to this [Blog post](https://handnot2.github.io/blog/elixir/aws-signature-sigaws))

  Make sure to add this in your supervision tree.
  """

  @behaviour Sigaws.Provider
  use GenServer

  require Logger

  import Sigaws.Util, only: [check_expiration: 1, parse_amz_dt: 1, signing_key: 4]

  @creds_table :sigaws_creds

  def pre_verification(%Sigaws.Ctxt{} = ctxt) do
    regions =
      (Application.get_env(:sigaws_quickstart_provider, :regions) || "us-east-1")
      |> String.split(",")
      |> Enum.map(&String.trim/1)
    services =
      (Application.get_env(:sigaws_quickstart_provider, :services) || "my-service")
      |> String.split(",")
      |> Enum.map(&String.trim/1)
    cond do
      !(ctxt.region in regions)   -> {:error, :unknown, "region"}
      !(ctxt.service in services) -> {:error, :unknown, "service"}
      true -> check_expiration(ctxt)
    end
  end

  def signing_key(%Sigaws.Ctxt{access_key: id, signed_at_amz_dt: amz_dt,
      region: r, service: s}) do

    with [{^id, se}] <- :ets.lookup(@creds_table, id),
         {:ok, dt} <- parse_amz_dt(amz_dt)
    do
      signing_key(DateTime.to_date(dt), r, s, se)
    else
      {:error, _, _} = error -> error
      _ -> {:error, :unknown, "access_key"}
    end
  rescue
    _ -> {:error, :unknown, "access_key"}
  end

  def start_link(gs_opts \\ []) do
    GenServer.start_link(__MODULE__, [], gs_opts)
  end

  def init([]) do
    send(self(), :load)
    state = %{}
    {:ok, state}
  end

  def handle_info(:load, state) do
    load_creds(Application.get_env(:sigaws_quickstart_provider, :creds_file))
    {:noreply, state}
  end

  defp load_creds(nil), do: load_creds("sigaws_quickstart.creds")
  defp load_creds(file) when is_binary(file) do
    if :ets.info(@creds_table) != :undefined do
      :ets.delete(@creds_table)
    end

    :ets.new(@creds_table, [:set, :protected, :named_table])
    try do
      file
      |> File.stream!()
      |> Stream.filter(&(Regex.match?(~r/.+:.+/, &1)))
      |> Stream.map(&(String.trim_trailing(&1, "\n")))
      |> Stream.map(fn l ->
           [id, se] = l |> String.split(":", parts: 2)
           {String.trim(id), String.trim(se)}
         end)
      |> Enum.map(fn {id, se} -> :ets.insert(@creds_table, {id, se}) end)
    rescue
      e -> Logger.log(:error, "ERROR reading #{file}: #{inspect e}")
    end
  end
end
