defmodule Mix.Tasks.Step1ReadPrint do
    use Mix.Task

    def run(_), do: loop()

    def loop() do
        case IO.gets(:stdio, "user> ") do
            :eof -> 0
            {:error, reason} ->
                IO.inspect(reason)
                1
            line ->
                form = Mal.read(String.trim(line))
                IO.puts(:stdio, Mal.print(form))
                loop()
        end
    end
end