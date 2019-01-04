defmodule Mal.Env do
  @coreenv %{
    "+" => {:fn, &+/2},
    "-" => {:fn, &-/2},
    "*" => {:fn, &*/2},
    "/" => {:fn, &//2},
  }

  def new() do
    {@coreenv, nil}
  end

  def new(parent) do
    {%{}, parent}
  end

  def get(nil, key), do: throw({:error, "#{key} not found"})

  def get({env, parent_env}, key) do
    case Map.get(env, key) do
      nil -> get(parent_env, key)
      v -> v
    end
  end

  def set({env, parent}, key, value) do
    {Map.put(env, key, value), parent}
  end
end
