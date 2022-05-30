## Hints

Cairo is a non-deterministic programming language, 
it allows external programs to interact with the execution of a Cairo program.

A hint is a piece of python code that is inserted in a Cairo program.
Hints are attached to a Cairo instruction by encapsulating the hint code with the syntax:
```
    %{ 
        # Python hint goes here 
    %}
```

For instance, to factor a number, you could let an external prover do the computation for you and verify the result afterwards.
```
    let n = 1337
    local p
    local q
    %{
        ids.p = 191
        ids.q = 7
    %}
    assert n = p * q
```

Hints are not part of the Cairo bytecode, they are not proven and do not count in the total number of steps.

More information on how to use hints:
https://www.cairo-lang.org/docs/hello_cairo/program_input.html#hints
