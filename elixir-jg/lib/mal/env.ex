defmodule Mal.Env do
  alias Mal.Evaluator
  alias Mal.Forms
  import Mal.Types

  @spec new() :: Types.env()
  def new() do
    env =
      kernel_funs()
      |> Enum.concat(mod_to_function_list(Mal.CoreFunctions))
      |> Enum.map(fn {k, v} -> {k, %Forms.Interop{fn: v}} end)
      |> Map.new()

    env
  end

  def get(%{} = env, key) do
    case Map.get(env, key) do
      nil -> throw({:error, "Symbol #{key} not found"})
      v -> v
    end
  end

  def set(env, %Forms.Symbol{name: key}, expr) do
    Map.put(env, key, expr)
  end

  def set(env, [], []), do: env

  def set(env, [key | binds], [e | exprs]) do
    env = set(env, key, e)
    set(env, binds, exprs)
  end

  def set(_env, key, expr), do: throw({:error, :invalid_args, "key = #{inspect(key)}, value = #{expr}"})

  def merge(a, b), do: Map.merge(a, b)

  defp kernel_funs() do
    [
      {"+", &+/2},
      {"-", &-/2},
      {"*", &*/2},
      {"/", &//2},
      {"=", &==/2},
      {"<", &</2},
      {">", &>/2},
      {"<=", &<=/2},
      {">=", &>=/2}
    ]
    |> Enum.map(fn {name, f} -> {name, &apply(f, &1)} end)
  end

  defp mod_to_function_list(mod) do
    mod.__info__(:functions)
    |> Enum.map(fn {f, a} -> {Atom.to_string(f), Function.capture(mod, f, a)} end)
  end
end
