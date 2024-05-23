const std = @import("std");
const zigthesis = @import("zigthesis");
const utils = @import("utils");

test "falsify" {
    zigthesis.falsify(struct {
        pub fn pred(args: struct { i32, i32, i32 }) bool {
            const x = args[0];
            const y = args[1];
            const z = args[2];

            return (x + y) * z == x * (y + z);
        }
    }.pred, "Weid Distributive");

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
            const l1 = args[0];

            return utils.sum(l1[0..]) < 100;
        }
    }.pred, "Sum Less Than 100");

    zigthesis.falsify(struct {
        pub fn pred(args: struct { [6]u8 }) bool {
            const x = args[0];

            return std.mem.indexOf(u8, &x, "xyz") == null;
        }
    }.pred, "'xyz' Not a Substring"); //can view the falsifying case in string format by printing out with {s}

    zigthesis.falsify(struct {
        pub fn pred(args: struct { [3]i32, [3]i32 }) bool {
            const l1 = args[0];
	    const l2 = args[1];

	    const combined = utils.sumPairwise(l1[0..],l2[0..]);

            return combined.len == l1.len;
        }
    }.pred, "Length of Pairwise List Sum");

}
