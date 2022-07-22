defmodule RiverTest do
  use ExUnit.Case
  doctest River

  alias River

  describe "main" do 
    test "OP_ADD" do 
      input = "1 2 OP_ADD"
      expected_output = [3]

      assert expected_output == River.main(input)
    end 

    test "OP_SUB" do 
      input = "2 1 OP_SUB"
      expected_output = [1]

      assert expected_output == River.main(input)
    end 

    test "OP_EQUAL" do 
      input = "1 2 OP_EQUAL"
      expected_output = [0]

      assert expected_output == River.main(input)

      input = "2 2 OP_EQUAL"
      expected_output = [1]

      assert expected_output == River.main(input)
    end 

    test "OP_VERIFY" do 
      input = "0 OP_VERIFY"
      expected_output = [0]

      assert expected_output == River.main(input)

      input = "4 OP_VERIFY"
      expected_output = [1]

      assert expected_output == River.main(input)
    end 

    test "OP_IF OP_ENDIF" do 
      input = "0 OP_IF 3 OP_ELSE 5 6 OP_ENDIF 4 5 6"
      expected_output = [6, 5, 4, 6, 5, 0]

      assert expected_output == River.main(input)
    end 

    test "OP_ELSE OP_ENDIF" do 
      input = "1 OP_IF 3 OP_ELSE 5 6 OP_ENDIF 4 5 6"
      expected_output = [6, 5, 4, 3, 1]

      assert expected_output == River.main(input)
    end 
  end 

  describe "construct_input_list" do 
    test "works for basic integers and operators" do 
      input = "1 2 3 OP_ADD 4 OP_SUB 5 OP_VERIFY 6 OP_EQUAL"
      expected_output = ["1", "2", "3", "OP_ADD", "4", "OP_SUB", "5", "OP_VERIFY", "6", "OP_EQUAL"]
      assert expected_output == River.construct_input_list(input)
    end 

    test "works for contional statements" do 
      input = "1 2 OP_IF 3 OP_ADD OP_ELSE 5 6 OP_SUB OP_ENDIF 4 5 OP_VERIFY 6"
      conditional = %Conditional{
        if_statement: ["3", "OP_ADD"],
        else_statement: ["5", "6", "OP_SUB"]
      }
      expected_output = ["1", "2", conditional, "4", "5", "OP_VERIFY", "6"]
      assert expected_output == River.construct_input_list(input)
    end
  end 

  describe "validate_input_list" do
    test "returns validated list when all input elements are valid" do
      input = ["1", "2", "OP_ADD", "3", "OP_SUB", "0", "OP_EQUAL", "OP_VERIFY"]
      expected_output = [1, 2, :OP_ADD, 3, :OP_SUB, 0, :OP_EQUAL, :OP_VERIFY]

      assert {:ok, expected_output} == River.validate_input_list(input)
    end

    test "returns validated list when input elements contain conditional" do
      conditional = %Conditional{
        if_statement: ["2", "OP_ADD"],
        else_statement: ["3", "OP_SUB"]
      }

      input = ["0", conditional, "4", "5", "6"]

      validated_conditional = %Conditional{
        if_statement: [2, :OP_ADD],
        else_statement: [3, :OP_SUB]
      }

      expected_output = [0, validated_conditional, 4, 5, 6]

      assert {:ok, expected_output} == River.validate_input_list(input)
    end

    test "returns error message for invalid input" do
      input = ["A", "2", "OP_ADD", "3", "OP_SUB", "0", "OP_EQUAL"]
      expected_output = "Input A is invalid, must be an integer, OP_CODE or conditional"

      assert {:error, expected_output} == River.validate_input_list(input)
    end
  end
end
