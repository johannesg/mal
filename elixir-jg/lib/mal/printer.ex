defmodule Mal.Printer do
  alias Mal.Forms

  def print(:eof), do: ""
  def print(nil), do: "nil"
  def print(true), do: "true"
  def print(false), do: "false"
  def print("" <> str) do
    "\"" <> print_str(str) <> "\""
  end

  def print(%Forms.Symbol{name: name}), do: name

  def print(%Forms.List{list: list}), do: print_list("(", list, ")")
  def print(%Forms.Quote{form: q}), do: "(quote #{print(q)})"
  def print(%Forms.QuasiQuote{form: q}), do: "(quasiquote #{print(q)})"
  def print(%Forms.Unquote{form: q}), do: "(unquote #{print(q)})"
  def print(%Forms.SpliceUnquote{form: q}), do: "(splice-unquote #{print(q)})"
  def print(%Forms.Deref{form: q}), do: "(deref #{print(q)})"

  def print(%Forms.Meta{meta: meta, form: form}) do
    "(with-meta #{print(form)} #{print(meta)})"
  end

  def print(%Forms.Interop{fn: f}), do: "#{inspect f}"
  def print(%Forms.Fn{fn: f}), do: "#{inspect f}"

  def print(list) when is_list(list), do: print_list("[", list, "]")

  def print(%_{} = s), do: "#{inspect s}"
  def print(map) when is_map(map) do
    "{" <>
      (map
       |> Enum.map(fn {k, v} ->
         "#{print(k)} #{print(v)}"
       end)
       |> Enum.join(" ")) <> "}"
  end

  def print(kw) when is_atom(kw), do: ":#{kw}"
  def print(any) do
    inspect(any)
  end

  defp print_str(str) do
    str
    |> String.replace("\n", "\\n")
    |> String.replace("\"", "\\\"")
  end

  defp print_list(a, list, b) do
    a <>
      (list
       |> Enum.map(&print/1)
       |> Enum.join(" ")) <> b
  end
end
