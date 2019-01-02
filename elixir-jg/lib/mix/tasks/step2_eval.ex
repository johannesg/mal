defmodule Mix.Tasks.Step2Eval do
  use Mix.Task

  def run(_), do: loop()

  defdelegate read(str), to: Mal.Reader

  defdelegate eval(ast, env), to: Mal.Evaluator

  defdelegate print(ast), to: Mal.Printer

  def rep(str) do
    env = %{
      "+" => {:fn, &Mal.CoreFunctions.add/2 },
      "++" => {:fn, fn (a, b) -> a + b end },
      "a" => {:string, "abcd"}
    }

    str
    |> read()
    |> eval(env)
    |> print()
  end

  def loop() do
    case IO.gets(:stdio, "user> ") do
      :eof ->
        0

      {:error, reason} ->
        IO.inspect(reason)
        1

      line ->
        IO.puts(:stdio, rep(line))
        loop()
    end
  end
end
