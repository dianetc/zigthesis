const std = @import("std");

// ascii mapping
const A = 65;
const z = 122;


pub fn generateField(random: std.rand.Random, comptime T: type) T {  
    switch (@typeInfo(T)) {
        .Int => {
            if (T == u8){
                return random.intRangeAtMost(T, A, z);
            } else {
                return random.intRangeAtMost(T, std.math.pow(i32, -10, 3), std.math.pow(i32, 10, 3));
            }
        },
        .Float => {
            return random.float(T);
        },
        .Array => |array_info| {
            var array: T = undefined;
            for (&array) |*item| {
                    item.* = generateField(random, array_info.child);
            }
            return array;
        },
        else => @compileError("Type '" ++ @typeName(T) ++ "' not supported "),
    }
}
