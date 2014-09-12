require Record

defmodule Alcsmg.Incident do
  use Ecto.Model

  schema "incidents" do
    field :inspection_id, :integer
    field :error_type,    :string
    field :path,          :string
    field :line_no,       :integer
    field :column_no,     :integer
    # TODO: add message
    # field :message,       :string
    field :msg_id,        :integer

    belongs_to :inspections, Alcsmg.Inspection
  end

  Record.defrecord :incident, Record.extract(:incident, from_lib: "alcs/include/alcs.hrl")

  def from_record(inc) do
    Enum.reduce incident(inc), %Alcsmg.Incident{}, fn
      {:location, {line}}, acc ->
        %{acc | line_no: line, column_no: 0}
      {:location, {line, column}}, acc ->
        %{acc | line_no: line, column_no: column}
      {field, value}, acc ->
        Map.put acc, field, value
    end
  end
end
