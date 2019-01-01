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
    end
  end

  def eval({_type, form}) do
    form
  end

  def print({:list, list}), do: print_list("(", list, ")")
  def print({:vector, list}), do: print_list("[", list, "]")

  def print({:string, str}) do
    "\"" <> print_str(str) <> "\""
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
