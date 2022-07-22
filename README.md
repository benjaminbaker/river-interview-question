# River Interview Question

## Running instructions
`mix compile`

`iex -S mix` to enter interactive mode

`River.main("_some input string_")` ex: River.main("0 OP_IF 3 OP_ELSE 5 6 OP_ENDIF 4 5 6")

## Improvements

Future features to add:
* Add ability to take floats/doubles
* Add ability to accept negative numbers
* Add ability for nested integers

Improvements to code: 
* Split up River.ex 
    * Move validations to their own file
    * Move evaluators to their own dedicated file
    * Perform conditional validation within the create_conditional function
* Improved validation
    *  Validate the stack with each OP_CODE - if there aren't sufficient numbers in the stack for an OP_CODE, return an error
