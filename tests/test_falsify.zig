const std = @import("std");
const zigthesis = @import("zigthesis");
const utils = @import("utils");

fn weirdDistributive(x: i32, y: i32, z: i32) bool {
    return (x + y) * z == x * (y + z);
}

fn commutativeMultiplication(x: i32, y: i32) bool {
    return x * y == y * x;
}

fn commutativeSubtraction(x: i32, y: i32) bool {
    return x - y == y - x;
}

fn associativityFloats(x: f32, y: f32, z: f32) bool {
    return (x + y) + z == x + (y + z);
}

fn sumLessThan100(l1: [3]i32) bool {
    return utils.sum(l1[0..]) < 100;
}

fn xyzNotSubstring(a: [6]u8) bool {
    return std.mem.indexOf(u8, &a, "xyz") == null;
}

fn lengthOfPairwiseListSum(l1: [3]i32, l2: [3]i32) bool {
    const combined = utils.sumPairwise(l1[0..], l2[0..]);
    return combined.len == l1.len;
}

test "falsify" {
    try zigthesis.falsify(weirdDistributive, "Weird Distributive");
    try zigthesis.falsify(commutativeMultiplication, "Commutative Property of Multiplication (Integers)");
    try zigthesis.falsify(commutativeSubtraction, "Commutative Property of Subtraction (Integers)");
    try zigthesis.falsify(associativityFloats, "Associativity of Floats");
    try zigthesis.falsify(sumLessThan100, "Sum Less Than 100");
    try zigthesis.falsify(xyzNotSubstring, "'xyz' Not a Substring");
    try zigthesis.falsify(lengthOfPairwiseListSum, "Length of Pairwise List Sum");
}
