defmodule Parser do
  @moduledoc """
  Parser module
  """

  @doc """
  Parse input string and return a list of strings.
  Returns empty list if input is empty

  Examples:
  iex> Parser.parse("")
  {:ok, []}

  iex> Parser.parse("(+ 1 2)")
  {:ok, ["+", "1", "2"]}

  iex> Parser.parse("(* (+ 1 2) 3))")
  {:ok, ["*", ["+", "1", "2"], "3"]}

  iex> Parser.parse(1)
  {:error, "Input argument must be a string."}
  """
  @spec parse(String.t()) :: {:ok, list(any())} | {:error, String.t()}
  def parse(input = "") when is_bitstring(input) do
    {:ok, []}
  end

  def parse(input) when is_bitstring(input) do
    result = read_parentheses(input, :start, {[], [], []})

    if result == :error do
      {:error, "Unbalanced parentheses"}
    else
      {:ok, result}
    end
  end

  def parse(_) do
    {:error, "Input argument must be a string."}
  end

  @doc """
  Tokenize input string list and return a list of tokens.

  Examples:
  iex> Parser.tokenize({:ok, ["+", "1", "2"]})
  {:ok, [:+, 1.0, 2.0]}

  iex> Parser.tokenize({:ok, ["*", ["+", "1", "2"], "3"]})
  {:ok, [:*, [:+, 1.0, 2.0], 3.0]}
  """
  def tokenize({:ok, inputs}) do
    {:ok, _tokenize(inputs)}
  end

  def tokenize({:error, message}), do: {:error, message}

  defp read_parentheses("", :start, {stack, [], []}), do: stack

  defp read_parentheses("(" <> rest, :start, {stack, [], []}) do
    [head, tail] = String.split(rest, " ", parts: 2, trim: true)

    if head == ")" do
      read_parentheses(tail, :start, {stack, [], []})
    else
      read_parentheses(tail, :open, {stack, [head], []})
    end
  end

  defp read_parentheses(")" <> rest, :start, {stack, [], []}),
    do: read_parentheses(rest, :start, {stack, [], []})

  defp read_parentheses(")" <> rest, :start, {stack, content, []}),
    do: read_parentheses(rest, :start, {[stack, content], [], []})

  defp read_parentheses(")" <> rest, :start, {stack, content, [head | tail]}),
    do: read_parentheses(rest, :start, {[stack, head, content], [], tail})

  defp read_parentheses(
         <<head::binary-size(1), rest::binary>>,
         :start,
         {stack, content, evacuation}
       ) do
    if head == " " do
      read_parentheses(rest, :open, {stack, content, evacuation})
    else
      read_parentheses(
        rest,
        :open,
        {stack, [head | Enum.reverse(content)] |> Enum.reverse(), evacuation}
      )
    end
  end

  defp read_parentheses("", :open, {stack, [], []}), do: stack

  defp read_parentheses(")" <> rest, :open, {[], content, []}),
    do: read_parentheses(rest, :start, {content, [], []})

  defp read_parentheses(")" <> rest, :open, {[], content, [head | tail]}),
    do: read_parentheses(rest, :start, {[head, content], [], tail})

  defp read_parentheses(")" <> rest, :open, {stack, content, []}),
    do: read_parentheses(rest, :start, {stack ++ content, [], []})

  defp read_parentheses(")" <> rest, :open, {stack, content, [head | tail]}),
    do: read_parentheses(rest, :start, {[stack, head, content], [], tail})

  defp read_parentheses("(" <> rest, :open, {stack, content, []}),
    do: read_parentheses(rest, :open, {stack, [], content})

  defp read_parentheses("(" <> rest, :open, {stack, content, evacuation}),
    do: read_parentheses(rest, :open, {stack, [], [content | evacuation]})

  defp read_parentheses(<<head::binary-size(1), rest::binary>>, :open, {stack, content, []}) do
    if head == " " do
      read_parentheses(rest, :open, {stack, content, []})
    else
      read_parentheses(rest, :open, {stack, [head | Enum.reverse(content)] |> Enum.reverse(), []})
    end
  end

  defp read_parentheses(
         <<head::binary-size(1), rest::binary>>,
         :open,
         {stack, content, evacuation}
       ) do
    if head == " " do
      read_parentheses(rest, :open, {stack, content, evacuation})
    else
      read_parentheses(
        rest,
        :open,
        {stack, [head | Enum.reverse(content)] |> Enum.reverse(), evacuation}
      )
    end
  end

  defp read_parentheses(_, _, {stack, content, evacuation}) do
    IO.puts(
      "Error stack: #{inspect(stack)}, content: #{inspect(content)}, evacuation: #{inspect(evacuation)}"
    )

    :error
  end

  defp _tokenize(inputs) do
    Enum.map(inputs, fn input ->
      if is_list(input) do
        _tokenize(input)
      else
        case Float.parse(input) do
          {float, _} -> float
          :error -> String.to_atom(input)
        end
      end
    end)
  end
end
