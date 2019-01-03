defmodule Mal.Evaluator do
  alias Mal.Env

  def eval({:symbol, sym}, env) do
    {Env.get(env, sym), env}
  end

  def eval({:list, []} = list, env), do: {list, env}

  def eval({:list, [{:symbol, "def!"} | args]}, env) do
    with(
      [{:symbol, key} | args] <- args,
      [arg] <- args,
      {value, env} <- eval(arg, env)
    ) do
      {value, Env.set(env, key, value)}
    else
      _ -> throw({:error, :invalid_args})
    end
  end

  def eval({:list, list}, env) do
    [f | args] = Enum.map(list, &eval_item(&1, env))

    {make_form(applyfn(f, args)), env}
  end

  def eval({:vector, vec}, env), do: {{:vector, Enum.map(vec, &eval_item(&1, env))}, env}
  def eval({:map, map}, env), do: {{:map, Enum.map(map, &eval_pair(&1, env))}, env}

  def eval(form, env) do
    {form, env}
  end

  defp eval_item(form, env) do
    {form, _env} = eval(form, env)
    form
    # TODO
  end

  defp eval_pair({{_t, _f} = key, {_t2, _f2} = value}, env) do
    with(
      {key, env} <- eval(key, env),
      {value, _env} <- eval(value, env)
    ) do
      {key, value}
    end
  end

  defp applyfn({:fn, f}, args) do
    args = Enum.map(args, fn {_, value} -> value end)
    apply(f, args)
  end

  defp applyfn(_, _), do: throw({:error, :not_a_function})

  defp make_form(term) when is_number(term), do: {:number, term}
  defp make_form(term) when is_atom(term), do: {:keyword, term}
  defp make_form(term) when is_list(term), do: {:vector, term}
  defp make_form(term) when is_map(term), do: {:map, term}

  defp make_form(term) when is_binary(term) do
    cond do
      String.valid?(term) -> {:string, term}
      true -> {:binary, term}
    end
  end

  defp make_form(term), do: {:term, term}
end
