## Hints

Cairo is a non-deterministic programming language, it allows external programs to 
interact with Cairo code.

A hint is a piece of python code that can interact with a Cairo program.
Hints are attached to a Cairo instruction by encapsulating the hint code with the syntax
`%{ #python hint goes here %}`.

For instance, to compute whether a felt is even or odd, you could let
and external prover do the computation for you and verify the result afterwards.

```
    let my_sum = 1337
    local a
    local b
    %{
        ids.a = 42
        ids.b = ids.my_sum - ids.a
    %}
    assert my_sum = a + b
```

More information on how to use hints:
https://www.cairo-lang.org/docs/hello_cairo/program_input.html#hints