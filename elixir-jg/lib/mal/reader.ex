defmodule Mal.Reader do
  require Logger

  alias Mal.Tokenizer
  alias Mal.Forms

  def read(str) do
    tokens = Tokenizer.read_tokens(str)

    case read_form(tokens) do
      :eof -> :eof
      {form, _rest} -> form
    end
  end

  def read_form([]), do: :eof
  def read_form([{:symbol, "("} | rest]), do: read_list(")", rest)
  def read_form([{:symbol, "["} | rest]), do: read_list("]", rest)
  def read_form([{:symbol, "{"} | rest]), do: read_map(rest)
  def read_form([{:symbol, "'"} | rest]), do: read_quote(:quote, rest)
  def read_form([{:symbol, "`"} | rest]), do: read_quote(:quasiquote, rest)
  def read_form([{:symbol, "~@"} | rest]), do: read_quote(:spliceunquote, rest)
  def read_form([{:symbol, "~"} | rest]), do: read_quote(:unquote, rest)
  def read_form([{:symbol, "@"} | rest]), do: read_quote(:deref, rest)
  def read_form([{:symbol, "^"} | rest]), do: read_meta(rest)
  def read_form([{:symbol, "nil"} | rest]), do: {nil, rest}
  def read_form([{:symbol, "true"} | rest]), do: {true, rest}
  def read_form([{:symbol, "false"} | rest]), do: {false, rest}
  def read_form([{:symbol, name} | rest]), do: {%Forms.Symbol{name: name}, rest}
  def read_form([{:keyword, kw} | rest]), do: {kw, rest}
  def read_form([{:number, n} | rest]), do: {n, rest}
  def read_form([{:string, s} | rest]), do: {s, rest}

  def read_form([form | _rest]),
    do: throw({:error, :unknown_token, "Unknown token: #{inspect(form)}"})

  def read_list(t, tokens), do: read_list([], t, tokens)
  def read_list(_list, _t, []), do: throw({:error, :unbalanced})

  def read_list(list, ")", [{:symbol, ")"} | rest]), do: {%Forms.List{list: list}, rest}
  def read_list(list, "]", [{:symbol, "]"} | rest]), do: {list, rest}

  def read_list(list, t, tokens) do
    {form, rest} = read_form(tokens)
    read_list(list ++ [form], t, rest)
  end

  def read_map(tokens), do: read_map(%{}, tokens)

  def read_map(_map, []), do: throw({:error, :unclosed_map})
  def read_map(map, [{:symbol, "}"} | rest]), do: {map, rest}

  def read_map(map, tokens) do
    with(
      {key, rest} <- read_form(tokens),
      {value, rest} <- read_form(rest)
    ) do
      read_map(Map.put(map, key, value), rest)
    else
      :eof -> throw({:error, :unclosed_map})
    end
  end

  def read_quote(q, tokens) do
    case read_form(tokens) do
      :eof ->
        throw({:error, :empty_quote})

      {form, rest} ->
        {make_quote(q, form), rest}
    end
  end

  def make_quote(:quote, form), do: %Forms.Quote{form: form}
  def make_quote(:quasiquote, form), do: %Forms.QuasiQuote{form: form}
  def make_quote(:spliceunquote, form), do: %Forms.SpliceUnquote{form: form}
  def make_quote(:unquote, form), do: %Forms.Unquote{form: form}
  def make_quote(:deref, form), do: %Forms.Deref{form: form}

  def read_meta(tokens) do
    with(
      {meta, rest} <- read_form(tokens),
      {form, rest} <- read_form(rest)
    ) do
      {%Forms.Meta{meta: meta, form: form}, rest}
    else
      :eof -> throw({:error, :incomplete_meta})
    end
  end
end
