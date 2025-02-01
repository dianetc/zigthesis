# Zigthesis

A  **small** library for falsifying a hypothesis.

The primary entry point into the library is the `falsify` function.

If this sounds eerily familiar to you, it should! Inspiration for this library was 
taken directly from the initial commits of the very popular [Hypothesis library](https://github.com/HypothesisWorks/hypothesis) 

Similar to falsify in Hypothesis, you give it a predicate and a specification for how to generate arguments to
that predicate, and it gives you a counterexample.

Currently, test cases can be added in `tests/test_falsify.zig`. Get started by building and running test examples via:

```bash
zig build
zig build test
```

An example test and output, 

```zig
fn weirdDistributive(x: i32, y: i32, z: i32) bool {
    return (x + y) * z == x * (y + z);
}
try zigthesis.falsify(weirdDistributive, "weird distributive");
```

Output:
```
weird distributive             failed for { 1, 1, 0 }
```

Zigthesis will return a success, if no falsifying test case was found within MAX_DURATION_MS (currently set at 5 seconds).


INITIAL REMARK: This is tiny and doesn't do much for now. Next steps would be to make a simple foundation for generating and testing properties with:
1. ~~Floats~~
2. ~~Arrays (of floats/integers)~~
3. ~~Vectors~~
4. ~~Strings~~
5. ~~User Defined Struct~~

## STATUS:

- Currently `main.zig` only has an empty main function. This is confusing. Is there a way refactor to make this more intuitive?

- Implemented a [bad shrinking](https://propertesting.com/book_shrinking.html) mechanism. More thought needs to be put into this. Currently shrinking in zigthesis is treated as a [post-facto process](https://dianetc.github.io/musings/initial_shrinking/). We must "integrate" shrinking into the generation process instead of afterwards in order to get minimizing falsifying cases. My next obvious step was to have the generator produce not just a plain value, but a structure (call it a sample) that contains both the generated value and a (possibly lazy) tree of shrink candidates. That way, if a property fails, we can traverse the tree to quickly locate a minimal failing case. This is easier said than done though. 

