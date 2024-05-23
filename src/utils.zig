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

// scales random.float to return within the range (min, max)
pub fn randomFloat(comptime T: type, min: T, max: T) T {
    return min + (max - min) * std.crypto.random.float(T);
}

