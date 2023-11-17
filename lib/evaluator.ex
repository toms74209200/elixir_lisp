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

  iex> Evaluator.eval([:-, 3, 1], 0)
  2

  iex> Evaluator.eval([:-, 3, 2, 1], 0)
  0

  iex> Evaluator.eval([:*, [:+, 1, 2], 3], 0)
  9
  """
  @spec eval(list(atom() | list(any())), number()) :: number()
  def eval([atom | args], acc) do
    case atom do
      :+ -> add(args, acc)
      :- -> minus(args, acc)
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

  defp minus(args, acc) do
    [minuend | subtrahends] = args

    minuend -
      (acc +
         Enum.reduce(subtrahends, acc, fn subtrahend, acc ->
           if is_list(subtrahend) do
             acc + eval(subtrahend, acc)
           else
             acc + subtrahend
           end
         end))
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
