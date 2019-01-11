defmodule Mal.Special do
  alias __MODULE__
  alias Mal.Env
  alias Mal.Evaluator
  alias Mal.Forms

  require Logger

  @specials %{
    "def!" => &Special.def!/2,
    "let*" => &Special.let/2,
    "do" => &Special.do_/2,
    "if" => &Special.if_/2,
    "fn*" => &Special.fn_/2
  }

  def is_special?(name) do
    Map.has_key?(@specials, name)
  end

  def call_special(name, args, env) do
    %{^name => f} = @specials
    f.(args, env)
  end

  def def!([%Forms.Symbol{} = key, arg], env) do
    {value, env} = Evaluator.eval(arg, env)
    {value, Env.set(env, key, value)}
  end

  def def!(args, _), do: throw({:error, :invalid_args, inspect(args)})

  def let([%Forms.List{list: bindings}, form], env), do: let(bindings, form, env)
  def let([bindings, form], env) when is_list(bindings), do: let(bindings, form, env)
  def let(bindings, _), do: throw({:error, :invalid_args, inspect(bindings)})

  defp let(bindings, form, env) do
    new_env = set_env(bindings, env)

    {result, _} = Evaluator.eval(form, new_env)
    {result, env}
  end

  defp set_env([], env), do: env
  defp set_env([b, e | bindings], env) do
    { res, env } = Evaluator.eval(e, env)
    env = Env.set(env, b, res)
    set_env(bindings, env)
  end

  defp set_env(_b, _env), do: throw({:error, :invalid_bindings })

  def do_(expr, env) do
    Enum.reduce(expr, {nil, env}, fn e, {_, env} ->
      Evaluator.eval(e, env)
    end)
  end

  def if_([ifexpr, thenexpr], env) do
    {result, env} = Evaluator.eval(ifexpr, env)

    case result do
      nil -> { nil, env }
      false -> { nil, env }
      _ -> Evaluator.eval(thenexpr, env)
    end
  end

  def if_([ifexpr, thenexpr, elseexpr], env) do
    {result, env} = Evaluator.eval(ifexpr, env)

    case result do
      nil -> Evaluator.eval(elseexpr, env)
      false -> Evaluator.eval(elseexpr, env)
      _ -> Evaluator.eval(thenexpr, env)
    end
  end

  def if_(_, _env), do: throw({:error, :invalid_args})

  def fn_([%Forms.List{list: binds} | body], env) do
    fn_(binds, body, env)
  end

  def fn_([binds | body], env) when is_list(binds) do
    fn_(binds, body, env)
  end

  def fn_(_, _env), do: throw({:error, :invalid_args})

  def fn_(binds, body, env) do
    # Logger.info("binds: #{inspect(binds)}")
    f = fn args, outer_env ->
      # Logger.info("args: #{inspect(args)}")
      # Logger.info("eval: #{inspect(body)}")
      inner_env = outer_env
      |> Env.merge(env)
      |> Env.set(binds, args)

      # Logger.info("env: #{inspect(inner_env)}")
      # Process.sleep(300)
      {result, _ } = do_(body, inner_env)
      {result, outer_env }
    end

    {%Forms.Fn{fn: f}, env}
  end
end
