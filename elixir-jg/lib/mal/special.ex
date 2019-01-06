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

  def do_(expr, env) do
    Enum.reduce(expr, {nil, env}, fn e, {_, env} ->
      Evaluator.eval(e, env)
    end)
  end


  def if_([ifexpr, thenexpr], env) do
    { result, env} = Evaluator.eval(ifexpr, env)
    case result do
      nil -> nil
      false -> nil
      _ -> Evaluator.eval(thenexpr, env)
    end
  end

  def if_([ifexpr, thenexpr, elseexpr], env) do
    { result, env} = Evaluator.eval(ifexpr, env)
    case result do
      nil -> Evaluator.eval(elseexpr, env)
      false -> Evaluator.eval(elseexpr, env)
      _ -> Evaluator.eval(thenexpr, env)
    end
  end

  def if_(_, _env), do: throw {:error, :invalid_args}

  def fn_([{:list, binds}, body], env) do
    fn_(binds, body, env)
  end
  def fn_([{:vector, binds}, body], env) do
    fn_(binds, body, env)
  end
  def fn_(_, _env), do: throw {:error, :invalid_args}

  def fn_(binds, body, env) do
    f = fn (args, outer_env) ->
      inner_env = Env.new(outer_env, binds, args)
      Evaluator.eval(body, inner_env)
    end

    { {:fnv, f }, env }

  end
end
