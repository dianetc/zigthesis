const std = @import("std");
const zigthesis = @import("zigthesis");
const utils = @import("utils");

// The following tests should all pass
fn commutativeMultiplication(x: i32, y: i32) bool {
    return x * y == y * x;
}

fn commutativeAddition(x: i32, y: i32) bool {
    return x + y == y + x;
}
test "Commutativity" {
    try std.testing.expect(!try zigthesis.falsify(commutativeMultiplication));
    try std.testing.expect(!try zigthesis.falsify(commutativeAddition));
}

fn associativityMultiplication(x: i32, y: i32, z: i32) bool {
    return (x + y) + z == x + (y + z);
}

fn associativityAddition(x: i32, y: i32, z: i32) bool {
    return (x * y) * z == x * (y * z);
}

test "Associativity" {
    try std.testing.expect(!try zigthesis.falsify(associativityMultiplication));
    try std.testing.expect(!try zigthesis.falsify(associativityAddition));
}

//The following tests should all fail
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

test "Strings and Lists" {
    try std.testing.expect(!try zigthesis.falsify(sumLessThan100));
    try std.testing.expect(!try zigthesis.falsify(xyzNotSubstring));
    try std.testing.expect(!try zigthesis.falsify(lengthOfPairwiseListSum));
}

fn weirdDistributive(x: i32, y: i32, z: i32) bool {
    return (x + y) * z == x * (y + z);
}

test "Weird Distributive" {
    try std.testing.expect(!try zigthesis.falsify(weirdDistributive));
}
