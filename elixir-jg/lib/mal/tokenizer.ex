defmodule Mal.Tokenizer do
  def read_tokens(str) do
    Stream.unfold(read_token(trim(str)), fn
      :eof ->
        nil

      {form, rest} ->
        {form, read_token(trim(rest))}
    end)
    |> Enum.to_list()
  end

  defp trim("," <> rest), do: trim(rest)
  defp trim(str), do: String.trim_leading(str)

  defp read_char(str), do: String.next_codepoint(str)

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

  def read_string(_str, "\n" <> rest), do: throw {:error, :newline_in_string}
  def read_string(_str, ""), do: throw {:error, :unclosed_string }
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

  def read_symbol(sym, ""), do: check_symbol(sym, "")

  def read_symbol(sym, rest) do
    {ch, rest2} = read_char(rest)

    cond do
      String.contains?(" \n,[]{}()'\"`;", ch) -> check_symbol(sym, rest)
      true -> read_symbol(sym <> ch, rest2)
    end
  end

  def check_symbol(":", _rest), do: throw {:error, :invalid_token}
  def check_symbol("::", _rest), do: throw {:error, :invalid_token}
  def check_symbol(":" <> keyword, rest), do: {{:keyword, keyword}, rest}
  def check_symbol(sym, rest), do: {{:symbol, sym}, rest}

  # def alpha?(cp), do: String.contains?("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", cp)
  def digit?(cp), do: String.contains?("0123456789", cp)
end
