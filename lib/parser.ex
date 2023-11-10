defmodule Parser do
  @doc """
  Parse input string and return lisp AST.
  Returns empty list if input is empty

  Examples:
  iex> Parser.parse("")
  {:ok, []}

  iex> Parser.parse(1)
  {:error, "Input argument must be a string."}
  """
  @spec parse(String.t()) :: {:ok, list(any())} | {:error, String.t()}
  def parse(input) when is_bitstring(input) do
    {:ok, []}
  end

  def parse(_) do
    {:error, "Input argument must be a string."}
  end
end
