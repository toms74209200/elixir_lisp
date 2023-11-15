defmodule Evaluator do
  @moduledoc """
  Evaluates a list of operations and returns the result.
  """

  @doc """
  Examples:
  iex> Evaluator.eval([:+, 1, 2], 0)
  3

  iex> Evaluator.eval([:+, 1, 2, 3], 0)
  6

  iex> Evaluator.eval([:*, [:+, 1, 2], 3], 0)
  9
  """
  @spec eval(list(atom() | list(any())), number()) :: number()
  def eval([atom | args], acc) do
    case atom do
      :+ -> add(args, acc)
      :* -> multiply(args, acc)
    end
  end

  defp add(args, acc) do
    acc +
      Enum.reduce(args, acc, fn arg, acc ->
        if is_list(arg) do
          eval(arg, acc) + acc
        else
          arg + acc
        end
      end)
  end

  defp multiply(args, acc) do
    Enum.reduce(args, acc, fn arg, acc ->
      if is_list(arg) do
        eval(arg, acc)
      else
        arg * acc
      end
    end)
  end
end
