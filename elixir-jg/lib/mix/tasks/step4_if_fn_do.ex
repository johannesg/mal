defmodule Mix.Tasks.Step4IfFnDo do
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
      other -> throw({:error, :unknown_match, other})
    end
  catch
    {:error, err} ->
      { "ERROR: #{err}", env }
    {:error, err, extra} ->
      { "ERROR: #{err}\nEXTRA: #{inspect(extra)}", env }
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
