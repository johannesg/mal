defmodule Mal.Evaluator do
  def eval({:symbol, sym}, env) do
    Map.get(env, sym, {:error, :symbol_not_found})
  end

  def eval({:list, []} = list, _env), do: list

  def eval({:list, list}, env) do
    [f | args] = Enum.map(list, fn i -> eval(i, env) end)

    {:unknown, applyfn(f, args)}
  end

  def eval(form, _env) do
    form
  end

  defp applyfn({:fn, f}, args) do
    args = Enum.map(args, fn {_, value} -> value end)
    apply(f, args)
  end

  defp applyfn(_, _), do: {:error, :not_a_function}
end
