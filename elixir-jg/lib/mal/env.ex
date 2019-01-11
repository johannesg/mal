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

    [env]
  end

  @spec new(Types.env(), [any()]) :: Types.env()
  def new(parents, bindings) do
    init([%{} | parents], bindings)
  end

  @spec new(Types.env(), [Types.symbol()], [any()]) :: Types.env()
  def new(parents, binds, exprs) do
    init([%{} | parents], binds, exprs)
  end

  @spec get(Types.env(), Types.symbol()) :: Types.env()
  def get([], key), do: throw({:error, "#{key} not found"})

  def get([env | parent], key) do
    case Map.get(env, key) do
      nil -> get(parent, key)
      v -> v
    end
  end

  @spec set(Types.env(), Types.symbol(), any()) :: Types.env()
  def set([env | parent], key, value) do
    [Map.put(env, key, value) | parent]
  end

  defp init(env, [], []), do: env

  defp init(env, [%Forms.Symbol{name: key} | binds], [e | exprs]) do
    # { value, env } = Evaluator.eval(e, env)
    env = set(env, key, e)
    init(env, binds, exprs)
  end

  defp init(_env, [_nosymbol | _binds], [_e | _exprs]), do: throw({:error, :must_be_a_symbol})
  defp init(_env, [], [_e | _exprs]), do: throw({:error, :too_many_exprs})
  defp init(_env, [_b | _binds], []), do: throw({:error, :too_many_binds})

  defp init(env, []), do: env

  defp init(env, [%Forms.Symbol{name: key}, expr | bindings]) do
    {value, env} = Evaluator.eval(expr, env)
    env = set(env, key, value)
    init(env, bindings)
  end

  defp init(_env, [{_t, _v}, _form | _bindings]), do: throw({:error, :must_be_a_symbol})
  defp init(_env, _b), do: throw({:error, :invalid_args})

  defp kernel_funs() do
    [ &+/2, &-/2, &*/2, &//2 ]
    |> Enum.map(fn f ->
      {:name, name} = Function.info(f, :name)
      { Atom.to_string(name), &apply(f, &1) }
    end)
  end

  defp mod_to_function_list(mod) do
    mod.__info__(:functions)
    # |> Enum.chunk_every(2)
    |> Enum.map(fn {f, a} -> {Atom.to_string(f), Function.capture(mod, f, a)} end)
  end
end
