defmodule Mix.Tasks.Step1ReadPrint do
  use Mix.Task

  def run(_), do: loop()

  defdelegate  read(str), to: Mal.Reader

  def eval(ast, _env), do: ast

  defdelegate  print(ast), to: Mal.Printer

  def rep(str) do
    str
    |> read()
    |> eval(nil)
    |> print()
  catch
    {:error, err} ->
      "ERROR: #{err}"
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
