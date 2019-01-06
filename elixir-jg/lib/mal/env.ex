defmodule Mal.Env do
  alias Mal.Evaluator
  import Mal.Types

  @coreenv %{
    "+" => {:fn, &+/2},
    "-" => {:fn, &-/2},
    "*" => {:fn, &*/2},
    "/" => {:fn, &//2}
  }

  @spec new() :: Types.env()
  def new() do
    [@coreenv]
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
  defp init(env, [{:symbol, key} | binds], [e | exprs]) do
    { value, env } = Evaluator.eval(e, env)
    env = set(env, key, value)
    init(env, binds, exprs)
  end
  defp init(_env, [_nosymbol | _binds], [_e | _exprs]), do: throw {:error, :must_be_a_symbol}
  defp init(_env, [], [_e | _exprs]), do: throw {:error, :too_many_exprs}
  defp init(_env, [_b | _binds], []), do: throw {:error, :too_many_binds}

  defp init(env, []), do: env
  defp init(env, [{:symbol, key}, expr | bindings]) do
    { value, env } = Evaluator.eval(expr, env)
    env = set(env, key, value)
    init(env, bindings)
  end

  defp init(_env, [{_t, _v}, _form | _bindings]), do: throw {:error, :must_be_a_symbol}
  defp init(_env, _b), do: throw {:error, :invalid_args}
end
