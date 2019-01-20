defmodule Mal.Printer do
  alias Mal.Forms

  def print(form, readably \\ false)

  def print(:eof, _), do: ""
  def print(nil, _), do: "nil"
  def print(true, _), do: "true"
  def print(false, _), do: "false"
  def print("" <> str, false) do
    "\"" <> escape_str(str) <> "\""
  end

  def print("" <> str, true) do
    str
  end

  def print(%Forms.Symbol{name: name}, _), do: name

  def print(%Forms.List{list: list}, readably), do: print_list("(", list, ")", readably)
  def print(%Forms.Quote{form: q}, readably), do: "(quote #{print(q, readably)})"
  def print(%Forms.QuasiQuote{form: q}, readably), do: "(quasiquote #{print(q, readably)})"
  def print(%Forms.Unquote{form: q}, readably), do: "(unquote #{print(q, readably)})"
  def print(%Forms.SpliceUnquote{form: q}, readably), do: "(splice-unquote #{print(q, readably)})"
  def print(%Forms.Deref{form: q}, readably), do: "(deref #{print(q, readably)})"

  def print(%Forms.Meta{meta: meta, form: form}, readably) do
    "(with-meta #{print(form, readably)} #{print(meta, readably)})"
  end

  # def print(%Forms.Interop{fn: f}, _), do: "#{inspect f}"
  def print(%Forms.Fn{fn: f}, _), do: "#{inspect f}"

  def print(list, readably) when is_list(list), do: print_list("[", list, "]", readably)

  def print(%_{} = s, _), do: "#{inspect s}"
  def print(map, readably) when is_map(map) do
    "{" <>
      (map
       |> Enum.map(fn {k, v} ->
         "#{print(k, readably)} #{print(v, readably)}"
       end)
       |> Enum.join(" ")) <> "}"
  end

  def print(kw, _) when is_atom(kw), do: ":#{kw}"
  def print(any, _) do
    inspect(any)
  end

  defp escape_str(str), do: escape_str(str, "")

  defp escape_str("", result), do: result
  defp escape_str("\n" <> rest, result), do: escape_str(rest, result <> "\\n")
  defp escape_str("\"" <> rest, result), do: escape_str(rest, result <> "\\\"")
  defp escape_str("\\" <> rest, result), do: escape_str(rest, result <> "\\\\")
  defp escape_str(rest, result) do
    { ch, rest } = String.next_codepoint(rest)
    escape_str(rest, result <> ch)
  end

  defp print_list(a, list, b, readably) do
    a <>
      (list
       |> Enum.map(&print(&1, readably))
       |> Enum.join(" ")) <> b
  end
end
