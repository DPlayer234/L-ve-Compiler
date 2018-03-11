# love-compiler

Create a 'in' directory and put your project in there.

To correctly use the --#const property, use indentation correctly and consistently. A constant is considered to be in the current scope if the amount of indentation (read: spaces + tabs) at the beginning of a line has not been less than the one the constant is on since it was defined. 'const' may also not be used as the name for constant variables. You can use constants within the definition of other constants. Also, only set values to constants which are constant at compile-time (strings, numbers, booleans).
