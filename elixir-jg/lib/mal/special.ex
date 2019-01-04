defmodule Mal.Special do
  alias Mal.Env
  alias Mal.Evaluator

  def def!([{:symbol, key}, arg], env) do
    {value, env} = Evaluator.eval(arg, env)
    {value, Env.set(env, key, value)}
  end

  def def!(_, _), do: throw({:error, :invalid_args})

  def let([{:list, bindings}, form], env), do: let(bindings, form, env)
  def let([{:vector, bindings}, form], env), do: let(bindings, form, env)
  def let(_, _), do: throw({:error, :invalid_args})

  defp let(bindings, form, env) do
    new_env = set_env(bindings, Env.new(env))

    {result, _} = Evaluator.eval(form, new_env)
    {result, env}
  end


  defp set_env([], env), do: env
  defp set_env([{:symbol, key}, form | bindings], env) do
    { form, env } = Evaluator.eval(form, env)
    env = Env.set(env, key, form)
    set_env(bindings, env)
  end

  defp set_env([{_t, _v}, _form | _bindings], _env), do: throw {:error, :expected_symbol}
  defp set_env(_b, _env), do: throw {:error, :invalid_args}
end
