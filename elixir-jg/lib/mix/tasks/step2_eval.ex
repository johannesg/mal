defmodule Mix.Tasks.Step2Eval do
  use Mix.Task

  def run(_), do: loop(Mal.Env.new())

  defdelegate read(str), to: Mal.Reader

  defdelegate eval(ast, env), to: Mal.Evaluator

  defdelegate print(ast), to: Mal.Printer

  def rep(str, env) do
    with(
      ast <- read(str),
      {ast, env} <- eval(ast, env),
      output <- print(ast)
    ) do
      {output, env}
    else
      _ -> throw({:error, :repl_error})
    end
  catch
    {:error, err} ->
      {"ERROR: #{err}", env}
  end

  def loop(env) do
    case IO.gets(:stdio, "user> ") do
      :eof ->
        0

      {:error, reason} ->
        IO.inspect(reason)
        1

      line ->
        {result, env} = rep(line, env)
        IO.puts(:stdio, result)
        loop(env)
    end
  end
end
