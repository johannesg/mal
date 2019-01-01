defmodule Mal do
  @moduledoc """
  Documentation for Mal.
  """

  @doc """

  ## Examples

  """

  def read(input) do
    case Mal.Reader.next(input) do
      {type, form, _rest } -> { type, form }
      {:error, err} -> {:error, err}
      :eof -> :eof
    end
  end

  def eval({_type, form}) do
    form
  end

  def print(:eof), do: ""
  def print({:list, list}), do: print_list("(", list, ")")
  def print({:vector, list}), do: print_list("[", list, "]")

  def print({:string, str}) do
    "\"" <> print_str(str) <> "\""
  end

  def print({:quote, q}), do: "(quote #{print(q)})"
  def print({:quasiquote, q}), do: "(quasiquote #{print(q)})"
  def print({:unquote, q}), do: "(unquote #{print(q)})"
  def print({:spliceunquote, q}), do: "(splice-unquote #{print(q)})"
  def print({:deref, q}), do: "(deref #{print(q)})"

  def print({:withmeta, {meta, form}}) do
    "(with-meta #{print(meta)} #{print(form)})"
  end

  def print({:error, err}) do
    "#{err}"
  end

  def print({_type, form}) do
    form
  end

  def print_str(str) do
    str
    |> String.replace("\n", "\\n")
    |> String.replace("\"", "\\\"")
  end

  def print_list(a, list, b) do
    a <> (
    list
    |> Enum.map(&print/1)
    |> Enum.join(" "))
    <> b
  end

  def rep(input) do
    input
    |> read
    |> eval
    |> print
  end
end
