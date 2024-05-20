const std = @import("std");

pub fn sum(array: []const i32) i32 {
    var result: i32 = 0;
    for (array) |item| {
        result += item;
    }
    return result;
}

// scales random.float to return within the range (min, max)
pub fn randomFloat(comptime T: type, min: T, max: T) T {
    return min + (max - min) * std.crypto.random.float(T);
}

