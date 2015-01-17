defmodule Alcsmg.SaveBodyJson do
  @moduledoc """
  just a copy of Plug.Parsers.JSON that allows to preserve original body
  """
  @behaviour Plug.Parsers
  import Plug.Conn

  def parse(conn, "application", "json", _headers, opts) do
    decoder = Keyword.get(opts, :json_decoder) ||
                raise ArgumentError, "JSON parser expects a :json_decoder option"
    conn
    |> read_body(opts)
    |> save_body(opts)
    |> decode(decoder)
  end

  def parse(conn, _type, _subtype, _headers, _opts) do
    {:next, conn}
  end

  defp save_body({:more, _, conn}, _opts) do
    {:error, :too_large, conn}
  end
  defp save_body({:ok, body, conn}, opts) do
    conn = case Keyword.fetch(opts, :body_save_key) do
      {:ok, key} -> put_private(conn, key, body)
      :error     -> conn
    end
    {:ok, body, conn}
  end

  defp decode({:more, _, conn}, _decoder) do
    {:error, :too_large, conn}
  end

  defp decode({:ok, "", conn}, _decoder) do
    {:ok, %{}, conn}
  end

  defp decode({:ok, body, conn}, decoder) do
    case decoder.decode!(body) do
      terms when is_map(terms)->
        {:ok, terms, conn}
      terms ->
        {:ok, %{"_json" => terms}, conn}
    end
  rescue
    e -> raise Plug.Parsers.ParseError, exception: e
  end
end
