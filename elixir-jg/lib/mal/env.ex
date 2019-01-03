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

  def get({env, _parent}, key) do
    case Map.get(env, key) do
      nil -> throw({:error, :symbol_not_found})
      v -> v
    end
  end

  def set({env, parent}, key, value) do
    {Map.put(env, key, value), parent}
  end
end
