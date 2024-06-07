const std = @import("std");
const zigthesis = @import("zigthesis");
const utils = @import("utils");

test "falsify" {
    try zigthesis.falsify(struct {
        pub fn pred(x: i32, y: i32, z: i32) bool {
            return (x + y) * z == x * (y + z);
        }
    }.pred , "Weid Distributive");

    try zigthesis.falsify(struct {
        pub fn pred(x: i32, y: i32) bool {
            return x * y == y * x;
        }
    }.pred, "Commutative Property of Multiplication (Integers)");

    try zigthesis.falsify(struct {
        pub fn pred(x: i32, y: i32) bool {
            return x - y == y - x;
        }
    }.pred, "Commutative Property of Subtraction (Integers)");

    try zigthesis.falsify(struct {
        pub fn pred(x: f32, y: f32, z: f32) bool {
            return (x + y) + z == x + (y + z);
        }
    }.pred, "Associativity of Floats");

    try zigthesis.falsify(struct {
        pub fn pred(l1: [3]i32 ) bool {
            return utils.sum(l1[0..]) < 100;
        }
    }.pred, "Sum Less Than 100");

    try zigthesis.falsify(struct {
        pub fn pred(a: [6]u8) bool {
            return std.mem.indexOf(u8, &a, "xyz") == null;
        }
    }.pred, "'xyz' Not a Substring"); //can view the falsifying case in string format by printing out with {s}

    try zigthesis.falsify(struct {
        pub fn pred(l1: [3]i32, l2: [3]i32 ) bool {
	        const combined = utils.sumPairwise(l1[0..],l2[0..]);

            return combined.len == l1.len;
        }
    }.pred, "Length of Pairwise List Sum");

}
