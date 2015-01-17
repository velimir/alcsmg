defimpl Poison.Encoder, for: Any do
  def encode(model, options) do
    module = model.__struct__
    key = module.__schema__(:source) |> Inflex.singularize
    
    model
    |> to_map
    |> (&(Dict.put %{}, key, &1)).()
    |> Poison.encode! options
  end

  # all fields has to be preloaded
  defp to_map(model_list) when is_list model_list do
    for model <- model_list, do: to_map model
  end

  defp to_map(model) do
    module = model.__struct__
    mapped = Enum.reduce module.__schema__(:associations), %{}, fn field, acc ->
      case module.__schema__(:association, field) do
        # TODO: fix that!
        # %Ecto.Reflections.BelongsTo{} -> acc
        _struct ->
          Map.get(model, field)
          |> (&(&1.__assoc__(:loaded))).()
          |> to_map
          |> (&(Dict.put acc, field, &1)).()
      end
    end

    mapped |> add_non_virtual model
  end

  defp add_non_virtual(dict, model) do
    module = model.__struct__
    module.__schema__(:keywords, model)
    |> Enum.into(dict)
  end
end
