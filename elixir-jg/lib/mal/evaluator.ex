defmodule Mal.Evaluator do
  alias Mal.Env
  alias Mal.Special
  alias Mal.Forms

  import Mal.Types
  require Logger

  require Mal.Special

  def eval(%Forms.Symbol{name: name}, env) do
    {Env.get(env, name), env}
  end

  def eval(%Forms.List{list: list} = form, env) do
    case list do
      [] ->
        {form, env}

      [%Forms.Symbol{name: name} | args] ->
        if Special.is_special?(name) do
            Special.call_special(name, args, env)
        else
            f = Env.get(env, name)
            {args, env} = eval_list(args, env)
            applyfn(f, args, env)
        end

      list ->
        {[f | args], env} = eval_list(list, env)

        applyfn(f, args, env)
    end
  end

  def eval(vec, env) when is_list(vec) do
    {vec, env} = eval_list(vec, env)
    {vec, env}
  end

  def eval(map, env) when is_map(map) do
    {map, env} =
      Enum.reduce(map, {%{}, env}, fn {key, value}, {map, env} ->
        with(
          {key, env} <- eval(key, env),
          {value, env} <- eval(value, env)
        ) do
          {Map.put(map, key, value), env}
        end
      end)

    {map, env}
  end

  def eval(form, env) do
    {form, env}
  end

  defp eval_list(list, env) do
    {newlist, env} =
      Enum.reduce(list, {[], env}, fn form, {newlist, env} ->
        {form, env} = eval(form, env)
        {[form | newlist], env}
      end)

    {Enum.reverse(newlist), env}
  end

  defp applyfn(%Forms.Interop{fn: f}, args, env) do
    {f.(args), env}
  end

  defp applyfn(%Forms.Fn{fn: f}, args, env) do
     f.(args, env)
  end

  defp applyfn(_, _, _), do: throw({:error, :not_a_function})
end
