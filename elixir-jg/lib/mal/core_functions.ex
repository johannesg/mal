defmodule Mal.CoreFunctions do
  # alias __MODULE__
  alias Mal.Forms

  require Logger

  def prn(forms) do
    forms
    |> Enum.map(fn f ->
      IO.puts(Mal.Printer.print(f))
    end)

    nil
  end

  def list(list), do: %Forms.List{list: list}

  def list?([%Forms.List{}]), do: true
  def list?([_]), do: false

  def count([%Forms.List{list: list}]), do: Enum.count(list)
  def count([nil]), do: 0

  def empty?([[]]), do: true
  def empty?([%Forms.List{list: []}]), do: true
  def empty?([_list]), do: false
end
