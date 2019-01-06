defmodule Mal.Types do
  @type form :: any()
  @type symbol :: {:symbol, String.t()}
  @type symbol_map :: %{symbol() => any()}
  @type env :: [symbol_map()]
end
