defmodule Mal.Forms do
  defmodule List do
    defstruct list: []
  end

  defmodule Symbol do
    @enforce_keys [:name]
    defstruct [:name]
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

  # defmodule Interop do
  #   @enforce_keys [:fn]
  #   defstruct [:fn]
  # end

  defmodule Fn do
    @enforce_keys [:fn]
    defstruct [:fn]
  end
end
