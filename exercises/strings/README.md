## Short strings

Short strings are a way to encode an ASCII string as a felt.
A short string can be defined by converting an ASCII string to its hexadecimal encoding.
The hexadecimal value can also be converted to decimal.
Short string are thus limited to 31 characters to fit into a felt.
The following code show equivalent ways of defining the same short string.
```
let s = 'Hello'
let s = 0x48656c6c6f
let s = 310939249775
```

Read more about short strings here https://www.cairo-lang.org/docs/how_cairo_works/consts.html#short-string-literals.

Strings of arbitrary size can be constructed from short strings, an example implementation can be found here https://github.com/topology-gg/caistring