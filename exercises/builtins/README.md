## Builtins

Builtins are low-level add-ons that you can import in your Cairo code and implement a specific set of functions in an optimized fashion.
Each builtin is assigned a separate memory location, accessible through regular Cairo memory calls using implicit parameters.
Some builtins have their own struct helpers you can import from `starkware.cairo.common.cairo_builtins`.

To call a builtin that computes a specific function, simply assign the input using `assert`, magically read the output and finally advance the builtin pointer.

Example of builtins include:
  - output: prints a felt in the output memory
  - range_check: verifies a felt value is lower than the range check bound
  - pedersen: compute the pedersen hash of two felt inputs (HashBuiltin*)
  - bitwise: computes logical bit operation on felts (BitwiseBuiltin*)
  - ecdsa: computes signatures on the Stark elliptic curve (SignatureBuiltin*)
  - ec_op: computes elliptic curve operation on the Stark curve (EcOpBuiltin*)

## Resources:
- https://www.cairo-lang.org/docs/how_cairo_works/builtins.html
- https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/cairo_builtins.cairo