defmodule Mix.Tasks.Step1ReadPrint do
  use Mix.Task

  def run(_), do: loop()

  defdelegate  read(str), to: Mal.Reader

  def eval(ast, _env), do: ast

  defdelegate  print(ast), to: Mal.Printer

  def loop() do
    case IO.gets(:stdio, "user> ") do
      :eof ->
        0

      {:error, reason} ->
        IO.inspect(reason)
        1

      line ->
        result =
          line
          |> read()
          |> eval(nil)
          |> print()

        IO.puts(:stdio, result)
        loop()
    end
  end
end
