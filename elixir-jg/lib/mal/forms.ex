defmodule Mal.Forms do
  alias Mal.Env
  alias Mal.Evaluator.Eval

defmodule List do
  defstruct list: []
end

defmodule Symbol do

  @enforce_keys [:name]
  defstruct [:name]

  defimpl Eval do
    def eval(%Symbol{name: name}, env) do
      {Env.get(env, name), env}
    end
  end
end

defmodule Meta do
  @enforce_keys [:meta, :form]
  defstruct [:meta, :form]
end

defmodule Quote do
  @enforce_keys [:form]
  defstruct [:form]
end

defmodule QuasiQuote do
  @enforce_keys [:form]
  defstruct [:form]
end

defmodule SpliceUnquote do
  @enforce_keys [:form]
  defstruct [:form]
end

defmodule Unquote do
  @enforce_keys [:form]
  defstruct [:form]
end

defmodule Deref do
  @enforce_keys [:form]
  defstruct [:form]
end

defmodule Fn do
  @enforce_keys [:fn]
  defstruct [:fn]
end

defmodule Fnv do
  @enforce_keys [:fn]
  defstruct [:fn]
end

end
