defmodule Mal.Evaluator do
  def eval({:symbol, sym}, env) do
    Map.get(env, sym, {:error, :symbol_not_found})
  end

  def eval({:list, []} = list, _env), do: list

  def eval({:list, list}, env) do
    [f | args] = Enum.map(list, &eval(&1, env))

    {:unknown, applyfn(f, args)}
  end

  def eval({{_t, _f} = key, {_t2, _f2} = value}, env), do: {eval(key, env), eval(value, env)}

  def eval({:vector, vec}, env), do: {:vector, Enum.map(vec, &eval(&1, env))}
  def eval({:map, map}, env), do: {:map, Enum.map(map, &eval(&1, env))}

  def eval(form, _env) do
    form
  end

  defp applyfn({:fn, f}, args) do
    args = Enum.map(args, fn {_, value} -> value end)
    apply(f, args)
  end

  defp applyfn(_, _), do: throw({:error, :not_a_function})
end
