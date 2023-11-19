defmodule Evaluator do
  @moduledoc """
  Evaluates a list of operations and returns the result.
  """

  @doc """
  Examples:
  iex> Evaluator.eval([:+, 1, 2], 0)
  {:ok, 3}

  iex> Evaluator.eval([:+, 1, 2, 3], 0)
  {:ok, 6}

  iex> Evaluator.eval([:-, 3, 1], 0)
  {:ok, 2}

  iex> Evaluator.eval([:-, 3, 2, 1], 0)
  {:ok, 0}

  iex> Evaluator.eval([:*, 2, 3], 0)
  {:ok, 6}

  iex> Evaluator.eval([:*, [:+, 1, 2], 3], 0)
  {:ok, 9}

  iex> Evaluator.eval([:/, 6, 2], 0)
  {:ok, 3.0}

  iex> Evaluator.eval([:/, 1, 0], 0)
  {:error, "Division by zero"}
  """
  @spec eval(list(atom() | list(any())), number()) :: {atom(), number() | String.t()}
  def eval(args, acc) do
    _eval(args, acc)
  end

  defp _eval([atom | args], acc) do
    case atom do
      :+ ->
        {:ok, add(args, acc)}

      :- ->
        {:ok, minus(args, acc)}

      :* ->
        {:ok, multiply(args, acc)}

      :/ ->
        if divide_by_zero?(args) do
          {:error, "Division by zero"}
        else
          {:ok, divide(args, acc)}
        end
    end
  end

  defp add(args, acc) do
    acc +
      Enum.reduce(args, acc, fn arg, acc ->
        if is_list(arg) do
          case _eval(arg, acc) do
            {:ok, result} ->
              result + acc

            error ->
              error
          end
        else
          arg + acc
        end
      end)
  end

  defp minus([minuend | subtrahends], acc) do
    minuend -
      (acc +
         Enum.reduce(subtrahends, acc, fn subtrahend, acc ->
           if is_list(subtrahend) do
             case _eval(subtrahend, acc) do
               {:ok, result} ->
                 acc + result

               error ->
                 error
             end
           else
             acc + subtrahend
           end
         end))
  end

  defp multiply(args, 0) do
    Enum.reduce(args, 1, fn arg, acc ->
      if is_list(arg) do
        case _eval(arg, 0) do
          {:ok, result} ->
            result * acc

          error ->
            error
        end
      else
        arg * acc
      end
    end)
  end

  defp multiply(args, acc) do
    Enum.reduce(args, acc, fn arg, acc ->
      if is_list(arg) do
        case _eval(arg, acc) do
          {:ok, result} -> result
          error -> error
        end

        _eval(arg, acc)
      else
        arg * acc
      end
    end)
  end

  defp divide([dividend | divisors], 0) do
    dividend /
      Enum.reduce(divisors, 1, fn divisor, acc ->
        if is_list(divisor) do
          case _eval(divisor, 0) do
            {:ok, result} -> result
            error -> error
          end
        else
          acc * divisor
        end
      end)
  end

  defp divide([dividend | divisors], acc) do
    dividend /
      (acc *
         Enum.reduce(divisors, acc, fn divisor, acc ->
           if is_list(divisor) do
             case _eval(divisor, acc) do
               {:ok, result} -> result * acc
               error -> error
             end
           else
             acc * divisor
           end
         end))
  end

  defp divide_by_zero?([_ | divisors]) do
    Enum.member?(divisors, 0)
  end
end
