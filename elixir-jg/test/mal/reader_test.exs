defmodule Mal.ReaderTest do
  use ExUnit.Case

  alias Mal.Reader

  doctest Mal

  test "parse strings" do
    assert Reader.next_token(~s("abc")) == {:string, "abc", "" }
    assert Reader.next_token(~s("abc def")) == {:string, "abc def", "" }
    assert Reader.next_token(~s("abc \\n def")) == {:string, "abc \n def", "" }
    assert Reader.next_token(~s("abc \\\\ def")) == {:string, "abc \\ def", "" }
    assert Reader.next_token(~s("abc \\" def")) == {:string, "abc \" def", "" }
    assert Reader.next_token(~s("abc \\ def")) == {:string, "abc \\ def", "" }
  end
end
