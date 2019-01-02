defmodule Mal.Reader do
  require Logger

  def read(str) do
    tokens = read_tokens(str)

    case read_form(tokens) do
      :eof -> :eof
      {:error, err, _rest} -> {:error, err}
      {form, _rest} -> form
    end
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
  def read_form([{_type, _token} = form | rest]), do: {form, rest}

  def read_list(_list, _t, []), do: {:error, :unbalanced, []}

  def read_list(_list, _t, [{:error, err} | rest]), do: {:error, err, rest}
  def read_list(list, ")", [{:symbol, ")"} | rest]), do: {{:list, list}, rest}
  def read_list(list, "]", [{:symbol, "]"} | rest]), do: {{:vector, list}, rest}

  def read_list(list, t, tokens) do
    {form, rest} = read_form(tokens)
    read_list(list ++ [form], t, rest)
  end

  def read_form_pair([], []), do: :eof
  def read_form_pair([_first], []), do: {:error, :expected_form, []}
  def read_form_pair([_first, _second] = forms, rest), do: {forms, rest}

  def read_form_pair(forms, tokens) do
    case read_form(tokens) do
      {:error, _err, _rest} = err ->
        err

      {form, rest} ->
        read_form_pair(forms ++ [form], rest)
    end
  end

  def read_map(_map, []), do: {:error, :unclosed_map, []}
  def read_map(map, [{:symbol, "}"} | rest]), do: {{:map, map}, rest}

  def read_map(map, tokens) do
    case read_form_pair([], tokens) do
      :eof ->
        {:error, :unclosed_map, tokens}

      {:error, _err, _rest} = err ->
        err

      {[key, value], rest} ->
        read_map(Map.put(map, key, value), rest)
    end
  end

  def read_quote(q, rest) do
    {form, rest} = read_form(rest)

    {{q, form}, rest}
  end

  def read_meta(rest) do
    case read_form_pair([], rest) do
      {:error, _err, _rest} = err ->
        err

      :eof ->
        {:error, :incomplete_meta, rest}

      {[meta, form], rest} ->
        {{:withmeta, {meta, form}}, rest}
    end
  end

  defp trim("," <> rest), do: trim(rest)
  defp trim(str), do: String.trim_leading(str)

  defp read_char(str), do: String.next_codepoint(str)

  def read_tokens(str) do
    Stream.unfold(read_token(trim(str)), fn
      :eof ->
        nil

      {:error, err, rest} ->
        {{:error, err}, read_token(trim(rest))}

      {form, rest} ->
        {form, read_token(trim(rest))}
    end)
    |> Enum.to_list()
  end

  def read_token(""), do: :eof
  #   def read_token("," <> rest), do: read_token(rest)
  def read_token(";;" <> rest), do: ignore_comment(rest)
  def read_token("+" <> rest), do: read_plusminus_or_number("+", rest)
  def read_token("-" <> rest), do: read_plusminus_or_number("-", rest)
  def read_token("\"" <> rest), do: read_string("", rest)
  def read_token("~@" <> rest), do: {{:symbol, "~@"}, rest}

  def read_token(str) do
    {ch, rest} = read_char(trim(str))

    cond do
      String.contains?("[]{}()'`~^@", ch) -> {{:symbol, ch}, rest}
      digit?(ch) -> read_number(str)
      true -> read_symbol(ch, rest)
    end
  end

  def ignore_comment(""), do: :eof
  def ignore_comment("\n" <> rest), do: read_token(rest)

  def ignore_comment(str) do
    {_ch, rest} = read_char(str)
    ignore_comment(rest)
  end

  def read_string(_str, "\n" <> rest), do: {:error, :newline_in_string, rest}
  def read_string(_str, ""), do: {:error, :unclosed_string, ""}
  def read_string(str, "\"" <> rest), do: {{:string, str}, rest}
  def read_string(str, "\\\\" <> rest), do: read_string(str <> "\\", rest)
  def read_string(str, "\\\"" <> rest), do: read_string(str <> "\"", rest)
  def read_string(str, "\\n" <> rest), do: read_string(str <> "\n", rest)

  def read_string(str, rest) do
    {ch, rest} = read_char(rest)
    read_string(str <> ch, rest)
  end

  def read_plusminus_or_number(ch, ""), do: {{:symbol, ch}, ""}

  def read_plusminus_or_number(ch, rest) do
    {ch2, _rest2} = read_char(rest)

    cond do
      digit?(ch2) -> read_number(ch <> rest)
      true -> read_symbol(ch, rest)
    end
  end

  def read_number(str) do
    {number, rest} = Integer.parse(str)
    {{:number, number}, rest}
  end

  def read_symbol(sym, ""), do: {{:symbol, sym}, ""}

  def read_symbol(sym, rest) do
    {ch, rest2} = read_char(rest)

    cond do
      String.contains?(" \n,[]{}()'\"`;", ch) -> {{:symbol, sym}, rest}
      true -> read_symbol(sym <> ch, rest2)
    end
  end

  def alpha?(cp), do: String.contains?("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", cp)
  def digit?(cp), do: String.contains?("0123456789", cp)
  def special?(cp), do: String.contains?("+-*/", cp)
  def whitespace?(cp), do: String.contains?(" \n", cp)
end
