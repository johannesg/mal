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

  def print({:list, list}) do
    "(" <> (
    list
    |> Enum.map(&print/1)
    |> Enum.join(" "))
    <> ")"
  end

  def print({:error, err}) do
    "ERROR"
  end

  def print({type, form}) do
    form
  end

  def rep(input) do
    input
    |> read
    |> eval
    |> print
  end
end
