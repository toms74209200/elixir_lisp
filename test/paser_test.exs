defmodule PaserTest do
  use ExUnit.Case
  doctest Parser

  test "normal" do
    assert Parser.parse("(+ 1 2)") |> Parser.tokenize() == {:ok, [:+, 1, 2]}
  end

  test "normal with nested" do
    assert Parser.parse("(* (+ 1 2) 3)") |> Parser.tokenize() == {:ok, [:*, [:+, 1, 2], 3]}
  end

  test "empty with input argument is empty string" do
    assert Parser.parse("") |> Parser.tokenize() == {:ok, []}
  end

  test "error with input argumant is not string" do
    assert Parser.parse(1) |> Parser.tokenize() == {:error, "Input argument must be a string."}
  end
end
