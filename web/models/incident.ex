require Record

defmodule Alcsmg.Incident do
  use Ecto.Model

  schema "incidents" do
    field :error_type,    :string
    field :path,          :string
    field :line_no,       :integer
    field :column_no,     :integer, default: 0
    field :message,       :string
    field :msg_id,        :integer
    
    belongs_to :inspection, Alcsmg.Inspection
  end

  Record.defrecord :incident, Record.extract(:incident, from_lib: "alcs/include/alcs.hrl")

  defp mapping, do: [
    file_name: :path,
    msg_id:    :msg_id,
    message:   fn
      msg when is_list(msg) ->      %{message: msg |> to_string}
    end,
    location:  fn
      {line, column} ->             %{line_no: line, column_no: column}
      line when is_integer(line) -> %{line_no: line, column_no: 0}
    end,
    type:      fn type -> %{error_type: to_string type} end,
  ]

  def from_record(inc) do
    Enum.reduce incident(inc), %Alcsmg.Incident{}, fn
      {field, value}, acc ->
        case mapping[field] do
          dst when is_atom(dst) ->
            Map.put acc, dst, value
          fun when is_function (fun) ->
            Map.merge acc, fun.(value)
        end
    end
  end
end
