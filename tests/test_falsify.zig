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
    try zigthesis.falsify(commutativeMultiplication, "multiplicative commutativity");
    try zigthesis.falsify(commutativeAddition, "additive commutativity");
}

fn associativityMultiplication(x: i32, y: i32, z: i32) bool {
    return (x + y) + z == x + (y + z);
}

fn associativityAddition(x: i32, y: i32, z: i32) bool {
    return (x * y) * z == x * (y * z);
}

test "Associativity" {
    try zigthesis.falsify(associativityMultiplication, "multiplicative associativity");
    try zigthesis.falsify(associativityAddition, "additive associativity");
}

pub fn symmetry(a: @Vector(2,i32), b: @Vector(2, i32)) bool {
    const ab = utils.manhattanDistance(a, b);
    const ba = utils.manhattanDistance(b, a);

    return ab == ba;
}
test "Distance Symmetry"{
    try zigthesis.falsify(symmetry, "symmetry");
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
    try zigthesis.falsify(sumLessThan100, "List sum < 100");
    try zigthesis.falsify(xyzNotSubstring, "xyz not a substring");
    try zigthesis.falsify(lengthOfPairwiseListSum, "pairwise list sum length");
}

fn weirdDistributive(x: i32, y: i32, z: i32) bool {
    return (x + y) * z == x * (y + z);
}

fn weirdAbsolute(x: i32, y: i32) bool {
    return @abs(x + y) == @abs(x) + @abs(y);
}

test "Distributive" {
    try zigthesis.falsify(weirdDistributive, "weird distributive");
    try zigthesis.falsify(weirdAbsolute, "weird absolute");
}

fn simpleStruct(instance: utils.structTest) bool {
    // this checks that fields can in fact be different
    return std.mem.eql(u8, &instance.a, &instance.b);
}
test "Struct Test"{
    try zigthesis.falsify(simpleStruct, "field entries in struct");
}

const AUnion = union(enum) {
    a : u8,
    b : u16,
    c : u32,
    d : u64,
    e : i8,
    f : i16,
    g : i32,
    h : i64,
    i : f32,
    j : f64,
    k : bool,
    l : void,
    m : [3]u8,
    n : [3]u16,
    o : [3]u32,
    p : [3]u64,
    q : [3]i8,
    r : []const u8,
    s : usize,
    t : *u8,
    u : ?u8,
    v : u9,
    w : []u64,
    x : []usize,
};

fn unionTest(instance: AnEnum) bool {
    return instance == .a;
}

test "Union Test" {
    try zigthesis.falsify(unionTest, "union test");
}

const AnEnum = enum { a, b, c };

fn enumTest(instance: AnEnum) bool {
    return instance == .a;
}

test "Enum Test" {
    try zigthesis.falsify(enumTest, "enum test");
}