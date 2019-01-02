defmodule Mal.Reader do
  require Logger

  alias Mal.Tokenizer

  def read(str) do
    tokens = Tokenizer.read_tokens(str)

    case read_form(tokens) do
      :eof -> :eof
      {:error, _} = err -> err
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
  def read_form([{:error, err} | _rest]), do: {:error, err}
  def read_form([form | rest]), do: {form, rest}

  def read_list(t, tokens), do: read_list([], t, tokens)
  def read_list(_list, _t, []), do: {:error, :unbalanced}

  def read_list(_list, _t, [{:error, err} | _rest]), do: {:error, err}
  def read_list(list, ")", [{:symbol, ")"} | rest]), do: {{:list, list}, rest}
  def read_list(list, "]", [{:symbol, "]"} | rest]), do: {{:vector, list}, rest}

  def read_list(list, t, tokens) do
    {form, rest} = read_form(tokens)
    read_list(list ++ [form], t, rest)
  end

  def read_form_pair(tokens), do: read_form_pair([], tokens)
  def read_form_pair([], []), do: :eof
  def read_form_pair([_first], []), do: {:error, :expected_form}
  def read_form_pair([_first, _second] = forms, rest), do: {forms, rest}

  def read_form_pair(forms, tokens) do
    case read_form(tokens) do
      {:error, _err} = err ->
        err

      {form, rest} ->
        read_form_pair(forms ++ [form], rest)
    end
  end

  def read_map(tokens), do: read_map(%{}, tokens)

  def read_map(_map, []), do: {:error, :unclosed_map}
  def read_map(map, [{:symbol, "}"} | rest]), do: {{:map, map}, rest}

  def read_map(map, tokens) do
    case read_form_pair(tokens) do
      :eof ->
        {:error, :unclosed_map, tokens}

      {:error, _err} = err ->
        err

      {[_key, {:symbol, "}"}], _rest} ->
        {:error, :missing_value}

      {[key, value], rest} ->
        read_map(Map.put(map, key, value), rest)
    end
  end

  def read_quote(q, rest) do
    {form, rest} = read_form(rest)

    {{q, form}, rest}
  end

  def read_meta(rest) do
    case read_form_pair(rest) do
      {:error, _err} = err ->
        err

      :eof ->
        {:error, :incomplete_meta}

      {[meta, form], rest} ->
        {{:withmeta, {meta, form}}, rest}
    end
  end
end
