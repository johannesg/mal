defmodule Mal.Env do
  alias Mal.Forms
  import Mal.Types

  require Logger

  @spec new() :: Types.env()
  def new() do
    Map.new()
  end

  def get(%{} = env, key) do
    case Map.fetch(env, key) do
      {:ok, v} -> v
      :error -> throw({:error, "Symbol #{key} not found"})
    end
  end

  def set(env, %Forms.Symbol{name: key}, expr) do
    Map.put(env, key, expr)
  end

  def set(env, [], []), do: env

  def set(env, [%Forms.Symbol{name: "&"}, more], exprs) do
    set(env, more, %Forms.List{list: exprs})
  end

  def set(env, [key | binds], [e | exprs]) do
    env = set(env, key, e)
    set(env, binds, exprs)
  end

  def set(_env, key, expr), do: throw({:error, :invalid_args, "key = #{inspect(key)}, value = #{expr}"})

  def merge(a, b), do: Map.merge(a, b)
end
