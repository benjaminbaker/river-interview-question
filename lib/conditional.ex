defmodule Conditional do
  use TypedStruct

  alias River

  typedstruct do
    field :if_statement, List.t(), enforce: true
    field :else_statement, List.t(), enforce: true
  end

  def create_conditional(input_list) do
    {["OP_IF" | if_statement], ["OP_ELSE" | else_statement]} =
      input_list
      |> Enum.split_while(fn input ->
        input != "OP_ELSE"
      end)

    %Conditional{
      if_statement: if_statement, 
      else_statement: else_statement
    }
  end
end