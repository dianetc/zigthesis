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

pub fn safeFloatOperation(comptime T: type, a: T, b: T, op: fn (f32, f32) f32) f32 {
    const a_float = @intToFloat(f32, a);
    const b_float = @intToFloat(f32, b);
    return op(a_float, b_float);
}