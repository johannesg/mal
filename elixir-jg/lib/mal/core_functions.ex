defmodule Mal.CoreFunctions do
  alias __MODULE__
  alias Mal.Forms

  @allfunctions %{
    "+" => &+/2,
    "-" => &-/2,
    "*" => &*/2,
    # "+" => &+/2
    "prn" => &CoreFunctions.prn/1,
    "/" => &//2
  }

  def get_all_functions() do
    @allfunctions
    |> Enum.map(fn {k, v} -> { k, %Forms.Interop{fn: v}} end)
    |> Map.new()
  end

  def prn(form) do
    Mal.Printer.print(form)

  end

end
