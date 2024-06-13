const std = @import("std");

pub fn sum(array: []const i32) i32 {
    var result: i32 = 0;
    for (array) |item| {
        result += item;
    }
    return result;
}

pub fn sumPairwise(list1: []const i32, list2: []const i32) []i32 {
    std.debug.assert(list1.len == list2.len);

    var result = std.heap.page_allocator.alloc(i32, list1.len) catch {
        std.debug.print("Memory allocation failed!\n", .{});
        return &[_]i32{};
    };
    defer std.heap.page_allocator.free(result);

    for (list1, 0..) |value, i| {
        result[i] = value + list2[i];
    }

    return result;
}

pub fn manhattanDistance(a: @Vector(2,i32), b: @Vector(2,i32)) u32 {
    return @abs(a[0] - b[0]) + @abs(a[1] - b[1]);
}

pub const structTest = struct {
    a: [3]u8,
    b: [3]u8,
};