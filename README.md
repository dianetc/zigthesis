
I wanted to learn a bit of Zig, so I created Zigthesis: a **small** library for falsifying a hypothesis.

The primary entry point into the library is the zigthesis.falsify function.

If this sounds eerily familiar to you, it should! Inspiration for this library was 
taken directly from the initial commits of the very popular [Hypothesis library](https://github.com/HypothesisWorks/hypothesis) 

Similar to falsify in Hypothesis, you give it a predicate and a specification for how to generate arguments to
that predicate and it gives you a counterexample.

Currently, tests can be added in ``src/main.zig". A current example 

``` zig
    zigthesis.falsify(struct {
        pub fn pred(args: struct { i32, i32, i32 }) bool {
            const x = args[0];
            const y = args[1];
            const z = args[2];

            return (x + y) * z == x * (y + z);
        }
    }.pred, "Example 1");

```

Output:
```
Falsifying case found for Example 1: { -574, 566, 837 }
```

Zigthesis will return that no falsifying case is found, if none was found within MAX_DURATION_MS (currently set at 15 seconds).


REMARK: This is tiny and doesn't do much for now. Next steps would be to make a simple foundation for generating and testing properties with:
1. ~~Floats~~
2. ~~Arrays (of floats/integers)~~
3. ~~Strings~~
4. Dictionaries 

Along with a bit of code of clean up (i.e. making a testing directory etc.)

In Hypothesis, they had both generating and minimizing components [(detailed here)](https://github.com/HypothesisWorks/hypothesis/blob/94037edcf6f5256214a8b39e266cc9452e34704c/README.rest)
that I do not implement. This will be required for richer test cases.

