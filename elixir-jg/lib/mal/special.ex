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
    new_env = Env.new(env, bindings)

    {result, _} = Evaluator.eval(form, new_env)
    {result, env}
  end

end
