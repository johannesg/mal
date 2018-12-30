defmodule Mix.Tasks.Step0Repl do
    use Mix.Task

    def run(_), do: loop()

    def loop() do
        case IO.gets(:stdio, "user> ") do
            :eof -> 0
            {:error, reason} ->
                IO.inspect(reason)
                1
            line -> 
                IO.puts(:stdio, Mal.rep(String.trim(line)))
                loop()
        end
    end
end