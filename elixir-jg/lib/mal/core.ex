defmodule Mal.Core do
  # alias __MODULE__
  alias Mal.Forms

  require Logger

  def list(%Forms.List{} = list), do: list
  def list(list), do: %Forms.List{list: list}

  def list?(%Forms.List{}), do: true
  def list?(_), do: false

  def count(nil), do: 0
  def count(%Forms.List{list: list}), do: Enum.count(list)
  def count(list), do: Enum.count(list)

  def empty?([]), do: true
  def empty?(%Forms.List{list: []}), do: true
  def empty?(_list), do: false

  def equals?(%Forms.List{list: a}, %Forms.List{list: b}), do: list_equals?(a, b)
  def equals?(a, %Forms.List{list: b}) when is_list(a), do: list_equals?(a, b)
  def equals?(%Forms.List{list: a}, b) when is_list(b), do: list_equals?(a, b)

  def equals?(a, b)
      when is_list(a) and is_list(b),
      do: list_equals?(a, b)

  def equals?(a, b), do: a == b

  def list_equals?([], []), do: true

  def list_equals?([a | as], [b | bs]) do
    case equals?(a, b) do
      false -> false
      true -> list_equals?(as, bs)
    end
  end

  def list_equals?(_a, _b), do: false

  def pr_str(%Forms.List{list: args}) do
    args
    |> Enum.map(&Mal.Printer.print/1)
    |> Enum.join(" ")
  end

  def str(%Forms.List{list: args}) do
    args
    |> Enum.map(&Mal.Printer.print(&1, true))
    |> Enum.join("")
  end

  def prn(%Forms.List{list: args}) do
    args
    |> Enum.map(&Mal.Printer.print/1)
    |> Enum.join(" ")
    |> IO.puts()

    nil
  end

  def println(%Forms.List{list: args}) do
    args
    |> Enum.map(&Mal.Printer.print(&1, true))
    |> Enum.join(" ")
    |> IO.puts()

    nil
  end
end
