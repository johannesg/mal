defmodule Mal do
  @moduledoc """
  Documentation for Mal.
  """

  @doc """

  ## Examples

  """

  def read(input) do
    input
  end

  def eval(input) do
    input
  end

  def print(input) do
    input
  end

  def rep(input) do
    input
    |> read
    |> eval
    |> print
  end
end
