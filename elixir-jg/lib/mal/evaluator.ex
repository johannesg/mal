defmodule Mal.Evaluator do
  alias Mal.Env
  alias Mal.Special

  def eval({:symbol, sym}, env) do
    {Env.get(env, sym), env}
  end

  def eval({:list, []} = list, env), do: {list, env}

  def eval({:list, [{:symbol, "def!"} | args]}, env), do: Special.def!(args, env)
  def eval({:list, [{:symbol, "let*"} | args]}, env), do: Special.let(args, env)

  # def eval({:list, [{:symbol, "let*"} | args]}, env) do
  #   env = Env.new(env)
  #   with(
  #     [{:list, bindings} | args] <- args,
  #     [arg] <- args,
  #     {value, env} <- eval(arg, env)
  #   ) do
  #     {value, Env.set(env, key, value)}
  #   else
  #     _ -> throw({:error, :invalid_args})
  #   end
  # end

  def eval({:list, list}, env) do
    {[f | args], env} = eval_list(list, env)

    {make_form(applyfn(f, args)), env}
  end

  def eval({:vector, vec}, env) do
    {vec, env} = eval_list(vec, env)
    {{:vector, vec}, env}
  end

  def eval({:map, map}, env) do
    {map, env} =
      Enum.reduce(map, {%{}, env}, fn {key, value}, {map, env} ->
        with(
          {key, env} <- eval(key, env),
          {value, env} <- eval(value, env)
        ) do
          {Map.put(map, key, value), env}
        end
      end)

    {{:map, map}, env}
  end

  def eval(form, env) do
    {form, env}
  end

  def eval_list(list, env) do
    {newlist, env} =
      Enum.reduce(list, {[], env}, fn form, {newlist, env} ->
        {form, env} = eval(form, env)
        {[form | newlist], env}
      end)

    {Enum.reverse(newlist), env}
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
