const std = @import("std");
const zigthesis = @import("zigthesis.zig");
const utils = @import("utils.zig");

pub fn main() void {
    zigthesis.falsify(struct {
        pub fn pred(args: struct { i32, i32, i32 }) bool {
            const x = args[0];
            const y = args[1];
            const z = args[2];

            return (x + y) * z == x * (y + z);
        }
    }.pred, "Example 1");

    zigthesis.falsify(struct {
        pub fn pred(args: struct { i32, i32 }) bool {
            const x = args[0];
            const y = args[1];

            return x * y == y * x;
        }
    }.pred, "Commutative Property of Multiplication (Integers)");

    zigthesis.falsify(struct {
        pub fn pred(args: struct { i32, i32 }) bool {
            const x = args[0];
            const y = args[1];

            return x - y == y - x;
        }
    }.pred, "Commutative Property of Subtraction (Integers)");

    zigthesis.falsify(struct {
        pub fn pred(args: struct { f32, f32, f32 }) bool {
            const x = args[0];
            const y = args[1];
            const z = args[2];

            return (x + y) + z == x + (y + z);
        }
    }.pred, "Associativity of Floats");

    zigthesis.falsify(struct {
        pub fn pred(args: struct { [3]i32 }) bool {
            const x = args[0];

            return utils.sum(x[0..]) < 100;
        }
    }.pred, "Sum of Elements in List");
}
