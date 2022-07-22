defmodule River do
  @moduledoc """
  Documentation for River.
  """

  alias Conditional

  @op_codes ["OP_ADD", "OP_SUB", "OP_EQUAL", "OP_VERIFY"]

  def main(string_input) do
    string_input
    |> construct_input_list()
    |> validate_input_list()
    |> case do 
      {:ok, validated_input_list} ->
        validated_input_list
        |> Enum.reduce([], fn input_item, accumulator ->
          evaluate_input(input_item, accumulator)
        end)
        |> IO.inspect()

      {:error, error_message} ->
        IO.inspect(error_message)
    end
  end

  # This method does the folowing:
  #  1. Splits the string input by spaces
  #  2. Chunks the string input list to group conditional statements into chunks
  #  3. Consolidates the chunked lists into one pre-validated list of input elements
  def construct_input_list(string_input) do
    string_input
    # 1
    |> String.split()
    #2 
    |> Enum.chunk_while([], fn string_element, accumulator ->
      case string_element do
        "OP_IF" ->
          {:cont, accumulator, ["OP_IF"]}

        "OP_ENDIF" ->
          {:cont, accumulator, []}

        element ->
          {:cont, accumulator ++ [element]}
      end
    end, 
    fn 
      [] -> {:cont, []}
      accumulator -> {:cont, accumulator, []}
    end)
    # 3
    |> Enum.reduce([], fn list, accumulator ->
       [first_element | _tail] = list

       if first_element == "OP_IF" do
         conditional = Conditional.create_conditional(list)
         accumulator ++ [conditional]
       else
         accumulator ++ list
       end
    end)
  end 

  def validate_input_list(input_list) do
    input_list
    |> Enum.reduce_while({:ok, []}, fn element, {:ok, accumulator} ->
      case validate_element(element) do
        {:ok, element} ->
          {:cont, {:ok, accumulator ++ [element]}}

        {:error, error_message} ->
          {:halt, {:error, error_message}}
      end
    end)
  end

  defp validate_element(element) when element in @op_codes do
    {:ok, String.to_atom(element)}
  end

  # This functional validates the list of OP Codes and integer inputs in the if and else
  # statements of the conditional, it will:
  #   - returns an error message if any is in an invalid format
  #   - return the element in the correct type if valid (ex: converts "1" -> 1)
  defp validate_element(%Conditional{if_statement: if_statement, else_statement: else_statement}) do
    validated_if_statement =
      if_statement
      |> Enum.reduce_while([], fn element, accumulator ->
        case validate_element(element) do
          {:ok, element} ->
            {:cont, accumulator ++ [element]}

          {:error, error_message} ->
            {:halt, error_message}
        end
      end)

    validated_else_statement =
      else_statement
      |> Enum.reduce_while([], fn element, accumulator ->
        case validate_element(element) do
          {:ok, element} ->
            {:cont, accumulator ++ [element]}

          {:error, error_message} ->
            {:halt, {:error, error_message}}
        end
      end)
    
    case {validated_if_statement, validated_else_statement} do
      {{:error, error_message}, _} ->
        {:error, error_message <> " in the if clause of conditional."}

      {_, {:error, error_message}} ->
        {:error, error_message <> " in the else clause of conditional."}

      _ ->
        conditional = 
          %Conditional{
            if_statement: validated_if_statement,
            else_statement: validated_else_statement
          }

        {:ok, conditional}
    end
  end

  defp validate_element(element) do
    if String.match?(element, ~r/^[0-9]*$/) do
      {:ok, String.to_integer(element)}
    else 
      {:error, "Input #{element} is invalid, must be an integer, OP_CODE or conditional"}
    end
  end

  defp evaluate_input(:OP_ADD, stack) do
    [integer_one, integer_two | tail] = stack
    [integer_two + integer_one | tail]
  end

  defp evaluate_input(:OP_SUB, stack) do
    [integer_one, integer_two | tail] = stack
    [integer_two - integer_one | tail]
  end

  defp evaluate_input(:OP_EQUAL, stack) do
    [integer_one, integer_two | tail] = stack
    if integer_one == integer_two do
      [1 | tail]
    else 
      [0 | tail]
    end
  end

  defp evaluate_input(:OP_VERIFY, stack) do
    [first_integer | tail] = stack
    if first_integer == 0 do
      [0 | tail]
    else 
      [1 | tail]
    end
  end

  defp evaluate_input(%Conditional{if_statement: if_statement, else_statement: else_statement}, stack) do
    [first_element | tail] = stack 
    
    if first_element != 0 do 
      if_statement
      |> Enum.reduce(stack, fn input_item, accumulator ->
        evaluate_input(input_item, accumulator)
      end)
    else
      else_statement
      |> Enum.reduce(stack, fn input_item, accumulator ->
        evaluate_input(input_item, accumulator)
      end)
    end
  end

  defp evaluate_input(integer, stack) do 
    [integer | stack]
  end 
end
