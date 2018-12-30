defmodule Mal.Reader do
  def next(str) do
    # parse(:unknown, "", txt, String.next_codepoint(txt))

    tokens = read_tokens(str)
    read_form(tokens)
  end

  def read_form([{:symbol, "("} | rest]), do: read_list([], rest)
  def read_form([{:error, err} | rest]), do: {:error, err, rest}
  def read_form([{type, token} | rest]), do: { type, token, rest }

  def read_list(_list, []), do: {:error, :unclosed_list}

  def read_list(_list, [{:error, err} | _rest]), do: {:error, err}
  def read_list(list, [{:symbol, ")"} | rest]), do: {:list, list, rest}

  def read_list(list, tokens) do
    { type, form, rest } = read_form(tokens)
    read_list(list ++ [{type, form}], rest)
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
  def next_token("(" <> rest), do: {:symbol, "(", rest}
  def next_token(")" <> rest), do: {:symbol, ")", rest}
  def next_token("+" <> rest), do: next_plusminus_or_number("+", rest)
  def next_token("-" <> rest), do: next_plusminus_or_number("-", rest)

  def next_token(str) do
    {ch, rest} = String.next_codepoint(trim(str))

    cond do
      digit?(ch) -> next_number(str)
      alpha?(ch) || special?(ch) -> next_symbol(ch, rest)
      true -> {:error, str, rest}
    end
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

    if !alpha?(ch) && !digit?(ch) && !special?(ch) do
      {:symbol, sym, rest}
    else
      next_symbol(sym <> ch, rest2)
    end
  end

  def alpha?(cp), do: String.contains?("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", cp)
  def digit?(cp), do: String.contains?("0123456789", cp)
  def special?(cp), do: String.contains?("+-*/", cp)
  def whitespace?(cp), do: String.contains?(" \n", cp)
end
