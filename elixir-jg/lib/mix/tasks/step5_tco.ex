defmodule Mix.Tasks.Step5Tco do
  use Mix.Task

  def run(_) do
    env = Mal.Env.new()

    # "(def! not (fn* (a) (if a false true)))"
    {_, env} =
      readfile("mal/core.mal")
      |> read()
      |> eval(env)

    loop(env)
  end

  def readfile(path) do
    with {:ok, dev} <- File.open(path, [:read, :utf8]) do
      IO.read(dev, :all)
    end
  end

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
  rescue
    e ->
      {"ERROR: #{inspect(e)}", env}
  catch
    {:error, err} ->
      {"ERROR: #{err}", env}

    {:error, err, extra} ->
      {"ERROR: #{err}\nEXTRA: #{inspect(extra)}", env}

    _ ->
      {"Some other error", env}
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
