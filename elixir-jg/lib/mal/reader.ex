defmodule Mal.Reader do
  require Logger

  def next(str) do
    # parse(:unknown, "", txt, String.next_codepoint(txt))

    tokens = read_tokens(str)
    read_form(tokens)
  end

  def read_form([]), do: :eof
  def read_form([{:symbol, "("} | rest]), do: read_list([], ")", rest)
  def read_form([{:symbol, "["} | rest]), do: read_list([], "]", rest)
  def read_form([{:symbol, "{"} | rest]), do: read_map(%{}, rest)
  def read_form([{:symbol, "'"} | rest]), do: read_quote(:quote, rest)
  def read_form([{:symbol, "`"} | rest]), do: read_quote(:quasiquote, rest)
  def read_form([{:symbol, "~@"} | rest]), do: read_quote(:spliceunquote, rest)
  def read_form([{:symbol, "~"} | rest]), do: read_quote(:unquote, rest)
  def read_form([{:symbol, "@"} | rest]), do: read_quote(:deref, rest)
  def read_form([{:symbol, "^"} | rest]), do: read_meta(rest)
  def read_form([{:error, err} | rest]), do: {:error, err, rest}
  def read_form([{type, token} | rest]), do: {type, token, rest}

  def read_list(_list, _t, []), do: {:error, :unbalanced}

  def read_list(_list, _t, [{:error, err} | _rest]), do: {:error, err}
  def read_list(list, ")", [{:symbol, ")"} | rest]), do: {:list, list, rest}
  def read_list(list, "]", [{:symbol, "]"} | rest]), do: {:vector, list, rest}

  def read_list(list, t, tokens) do
    {type, form, rest} = read_form(tokens)
    read_list(list ++ [{type, form}], t, rest)
  end

  def read_form_pair([], []), do: :eof
  def read_form_pair([_first], []), do: {:error, :expected_form, []}
  def read_form_pair([_first, _second] = forms, rest), do: {forms, rest}

  def read_form_pair(forms, tokens) do
    case read_form(tokens) do
      {:error, _err, _rest} = err -> err
      {type, form, rest} ->
        read_form_pair(forms ++ [{type, form}], rest)
    end
  end

  def read_map(map, tokens) do
    case read_form_pair([], tokens) do
      :eof -> {:error, :unclosed_map, tokens}

      {:error, _err, _rest} = err -> err

      {:symbol, "}", rest} -> {:map, map, rest}

      {[key, value], rest} ->
        read_map(Map.put(map, key, value), rest)
    end
  end

  def read_quote(q, rest) do
    {type, form, rest} = read_form(rest)

    {q, {type, form}, rest}
  end

  def read_meta(rest) do
    case read_form_pair([], rest) do
      {:error, _err, _rest} = err ->
        err

      :eof ->
        {:error, :incomplete_meta, rest}

      {forms, rest} ->
        {:withmeta, forms, rest}
    end
  end

  defp trim("," <> rest), do: trim(rest)
  defp trim(str), do: String.trim_leading(str)

  def read_tokens(str) do
    Stream.unfold(next_token(trim(str)), fn
      :eof ->
        nil

      {_type, _tok, rest} = curr ->
        {curr, next_token(trim(rest))}
    end)
    |> Enum.map(fn {type, tok, _rest} -> {type, tok} end)
    |> Enum.to_list()
  end

  def next_token(""), do: :eof
  #   def next_token("," <> rest), do: next_token(rest)
  def next_token(";;" <> rest), do: ignore_comment(rest)
  def next_token("+" <> rest), do: next_plusminus_or_number("+", rest)
  def next_token("-" <> rest), do: next_plusminus_or_number("-", rest)
  def next_token("\"" <> rest), do: next_string("", rest)
  def next_token("~@" <> rest), do: {:symbol, "~@", rest}

  def next_token(str) do
    {ch, rest} = String.next_codepoint(trim(str))

    cond do
      String.contains?("[]{}()'`~^@", ch) -> {:symbol, ch, rest}
      digit?(ch) -> next_number(str)
      true -> next_symbol(ch, rest)
    end
  end

  def ignore_comment(""), do: :eof
  def ignore_comment("\n" <> rest), do: next_token(rest)

  def ignore_comment(str) do
    {_ch, rest} = String.next_codepoint(trim(str))
    ignore_comment(rest)
  end

  def next_string(_str, "\n" <> rest), do: {:error, :newline_in_string, rest}
  def next_string(_str, ""), do: {:error, :unclosed_string, ""}
  def next_string(str, "\"" <> rest), do: {:string, str, rest}
  def next_string(str, "\\\\" <> rest), do: next_string(str <> "\\", rest)
  def next_string(str, "\\\"" <> rest), do: next_string(str <> "\"", rest)
  def next_string(str, "\\n" <> rest), do: next_string(str <> "\n", rest)

  def next_string(str, rest) do
    {ch, rest} = String.next_codepoint(rest)
    next_string(str <> ch, rest)
  end

  def next_plusminus_or_number(ch, ""), do: {:symbol, ch, ""}

  def next_plusminus_or_number(ch, rest) do
    {ch2, _rest2} = String.next_codepoint(rest)

    cond do
      digit?(ch2) -> next_number(ch <> rest)
      true -> next_symbol(ch, rest)
    end
  end

  def next_number(str) do
    {number, rest} = Integer.parse(str)
    {:number, number, rest}
  end

  @spec next_symbol(any(), binary()) :: {:symbol, any(), binary()}
  def next_symbol(sym, ""), do: {:symbol, sym, ""}

  def next_symbol(sym, rest) do
    {ch, rest2} = String.next_codepoint(rest)

    cond do
      String.contains?(" \n[]{}()'\"`,;", ch) -> {:symbol, sym, rest}
      true -> next_symbol(sym <> ch, rest2)
    end
  end

  def alpha?(cp), do: String.contains?("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", cp)
  def digit?(cp), do: String.contains?("0123456789", cp)
  def special?(cp), do: String.contains?("+-*/", cp)
  def whitespace?(cp), do: String.contains?(" \n", cp)
end
