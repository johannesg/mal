defmodule Mal.Reader do
  require Logger

  def next(str) do
    # parse(:unknown, "", txt, String.next_codepoint(txt))

    tokens = read_tokens(str)
    read_form(tokens)
  end

  def read_form([{:symbol, "("} | rest]), do: read_list([], ")", rest)
  def read_form([{:symbol, "["} | rest]), do: read_list([], "]", rest)
  def read_form([{:error, err} | rest]), do: {:error, err, rest}
  def read_form([{type, token} | rest]), do: {type, token, rest}

  def read_list(_list, _t, []), do: {:error, :unbalanced}

  def read_list(_list, _t, [{:error, err} | _rest]), do: {:error, err}
  def read_list(list, ")", [{:symbol, ")" } | rest]), do: {:list, list, rest}
  def read_list(list, "]", [{:symbol, "]" } | rest]), do: {:vector, list, rest}

  def read_list(list, t, tokens) do
    {type, form, rest} = read_form(tokens)
    read_list(list ++ [{type, form}], t, rest)
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
  def next_token("+" <> rest), do: next_plusminus_or_number("+", rest)
  def next_token("-" <> rest), do: next_plusminus_or_number("-", rest)
  def next_token("\"" <> rest), do: next_string("", rest)

  def next_token(str) do
    {ch, rest} = String.next_codepoint(trim(str))

    cond do
      String.contains?("[]{}()'`~^@", ch) -> {:symbol, ch, rest}
      digit?(ch) -> next_number(str)
      true -> next_symbol(ch, rest)
    end
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
