defmodule Alcsmg.GitDiff do
  defstruct from: nil, to: nil, headers: [], lines: []

  defmodule GitHeader,     do: defstruct line: "", from: nil, to: nil
  defmodule FromHeader,    do: defstruct line: "", file: nil
  defmodule ToHeader,      do: defstruct line: "", file: nil
  defmodule UnknownHeader, do: defstruct line: "", content: nil
  defmodule Hunk,          do: defstruct line: "", from_sl: 1, from_nl: 1, to_sl: 1, to_nl: 1, code: nil
  defmodule Code,          do: defstruct line: "", type: nil, code: nil, ln: nil

  def parse(content) do
    {:ok, pid} = StringIO.open(content)
    IO.stream(pid, :line)
    |> Enum.map(&(%{make_line(&1) | line: &1}))
    |> assembly
  end

  defp make_line(line) do
    cond do
      match = Regex.run(~r|^diff --git a/(.+?) b/(.+)$|, line) ->
        [_, from, to] = match
        %GitHeader{from: from, to: to}
      match = Regex.run(~r{^(\+\+\+|---) (?:(?:a|b)/)?(.*)$}, line) ->
        make_from_to(match)
      match = Regex.run(~r/^@@ -(\d+),?(\d*?) \+(\d+),?(\d*?) @@(.*)?$/, line) ->
        [_, from_sl, from_nl, to_sl, to_nl, code] = match
        [:from_sl, :from_nl, :to_sl, :to_nl]
        |> Enum.zip([from_sl, from_nl, to_sl, to_nl])
        |> Enum.map(fn {k, v} -> {k, v |> String.to_integer} end)
        |> Keyword.put(:code, code)
        |> Enum.into(%Hunk{})
      match = Regex.run(~r/^(-|\+| )(.*)$/, line) ->
        make_code(match)
      true ->
        %UnknownHeader{content: line}
    end
  end

  defp make_from_to([_, "---", file]), do: %FromHeader{file: file}
  defp make_from_to([_, "+++", file]), do: %ToHeader{file: file}

  defp make_code([_, "+", code]), do: %Code{type: :added, code: code}
  defp make_code([_, "-", code]), do: %Code{type: :removed, code: code}
  defp make_code([_, " ", code]), do: %Code{type: :same, code: code}

  defp assembly(lines) do
    lines
    |> group(&is_git_header/1)
    |> Enum.map(&to_diff_struct/1)
  end

  def group(lines, test_function, acc \\ [])

  def group([] = _lines, _clbk, acc), do: Enum.reverse(acc)
  def group([head | tail], clbk, acc) do
    {collected, rest} = Enum.split_while(tail, &(not clbk.(&1)))
    group(rest, clbk, [[head | collected] | acc])
  end


  defp to_diff_struct([%GitHeader{} = header| rest]) do
    {headers, hunks} = Enum.split_while(rest, &is_header/1)
    %FromHeader{file: from_file} = Enum.find(headers, &is_from_header/1)
    %ToHeader{file: to_file} = Enum.find(headers, &is_to_header/1)
    %Alcsmg.GitDiff{
      from: from_file, to: to_file, headers: [header | headers],
      lines: make_diff_lines(hunks)
    }
  end

  defp make_diff_lines(lines) do
    lines
    |> group(&is_hunk/1)
    |> Enum.flat_map(&to_diff_lines/1)
  end

  defp to_diff_lines([%Hunk{} = hunk | code_lines]) do
    to_diff_lines(code_lines, hunk, [])
  end

  defp to_diff_lines([], _, acc), do: Enum.reverse(acc)
  defp to_diff_lines([%Code{type: :same} = code | rest],
                     %Hunk{from_sl: from_sl, to_sl: sl} = hunk,
                     acc) do
    to_diff_lines(rest, %{hunk | from_sl: from_sl + 1, to_sl: sl + 1},
                  [%{code | ln: from_sl} | acc])
  end
  defp to_diff_lines([%Code{type: :removed} = code| rest],
                     %Hunk{from_sl: from_sl} = hunk,
                     acc) do
    to_diff_lines(rest, %{hunk | from_sl: from_sl + 1},
                  [%{code | ln: from_sl} | acc])
  end
  defp to_diff_lines([%Code{type: :added} = code | rest],
                     %Hunk{to_sl: sl} = hunk,
                     acc) do
    to_diff_lines(rest, %{hunk | to_sl: sl + 1},
                  [%{code | ln: sl} | acc])
  end

  # TODO: replace with macros
  def is_git_header(%GitHeader{}), do: true
  def is_git_header(_),            do: false

  defp is_header(%GitHeader{}),     do: true
  defp is_header(%FromHeader{}),    do: true
  defp is_header(%ToHeader{}),      do: true
  defp is_header(%UnknownHeader{}), do: true
  defp is_header(_),                do: false

  defp is_from_header(%FromHeader{}), do: true
  defp is_from_header(_), do: false

  defp is_to_header(%ToHeader{}), do: true
  defp is_to_header(_), do: false

  defp is_hunk(%Hunk{}), do: true
  defp is_hunk(_), do: false

  defimpl Collectable, for: Hunk do
    def into(original) do
      {original, fn
         hunk, {:cont, {k, v}} -> Map.put(hunk, k, v)
         hunk, :done           -> hunk
         _, :halt              -> :ok
       end}
    end
  end
end
