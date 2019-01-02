defmodule Mal do
  @moduledoc """
  Documentation for Mal.
  """

  @doc """

  ## Examples

  """

  defdelegate read(str), to: Mal.Reader

  defdelegate print(ast), to: Mal.Printer

  defdelegate eval(ast, env), to: Mal.Evaluator

  # def read(input) do
  #   Mal.Reader.read(input)
  # end

  def rep(input) do
    input
    |> read
    |> eval(nil)
    |> print
  end
end
