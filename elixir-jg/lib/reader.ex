defmodule Mal.Reader do
    
    def next(txt) do
        txt = String.trim_leading(txt)

        parse(:unknown, "", txt, String.next_codepoint(txt))
    end

    def parse(type, parsed, orig, {"(", rest}), do: parse_list([], String.next_codepoint(String.trim_leading(rest)))
    def parse(type, parsed, orig, {"(", rest}), do: parse_list([], String.next_codepoint(String.trim_leading(rest)))

    def parse(type, parsed, orig, {cp, rest}) do parse_list([], String.next_codepoint(String.trim_leading(rest)))
        cond do
            whitespace?(cp) -> { type, parsed, orig }
            true -> 
                parse(type, parsed <> cp, rest, String.next_codepoint(rest))
        end 
    end

    def parse(type, parsed, orig, nil), do: { type, parsed, orig }

    def parse_list(list, {")", rest}), do: {:list, list, rest }
    def parse_list(list, {cp, rest}) do
        { :incomplete_list, list, rest }
    end

    def parse_list(_list, nil), do: { :unclosed_list, nil }

    def alpha?(cp), do: String.contains?("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", cp)
    def digit?(cp), do: String.contains?("0123456789", cp)
    def whitespace?(cp), do: String.contains?(" \n", cp)
end