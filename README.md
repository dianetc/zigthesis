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
try zigthesis.falsify(weirdDistributive);
```

Output:
```
weird distributive             ✗ at: { -287, 121, -670 }
```

Zigthesis will return a success, if no falsifying test case was found within MAX_DURATION_MS (currently set at 5 seconds).


REMARK: This is tiny and doesn't do much for now. Next steps would be to make a simple foundation for generating and testing properties with:
1. ~~Floats~~
2. ~~Arrays (of floats/integers)~~
3. ~~Strings~~
4. Dictionaries 

~~Along with a bit of code of clean up (i.e. making a testing directory etc.).~~

In Hypothesis, they had both generating and minimizing components [(detailed here)](https://github.com/HypothesisWorks/hypothesis/blob/94037edcf6f5256214a8b39e266cc9452e34704c/README.rest)
that I do not implement. This will be required for richer test cases.

