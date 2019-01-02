defmodule Mix.Tasks.Step0Repl do
  use Mix.Task

  def run(_), do: loop()

  def read(str), do: str

  def eval(ast, _env), do: ast

  def print(ast), do: ast

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
