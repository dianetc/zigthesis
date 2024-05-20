const std = @import("std");

pub fn Generator(comptime Predicate: type) type {
    const Arg = @typeInfo(Predicate).Fn.params[0].type.?;

    return struct {
        pub fn generate() Arg {
            var arg: Arg = undefined;
            inline for (@typeInfo(Arg).Struct.fields) |field| {
                @field(arg, field.name) = generateField(field.type);
            }
            return arg;
        }
    };
}

fn generateField(comptime T: type) T {
    switch (@typeInfo(T)) {
        .Int => {
            return std.crypto.random.intRangeAtMost(T, std.math.pow(i32, -10, 3), std.math.pow(i32, 10, 3));
        },
        .Float => {
            return std.crypto.random.float(T);
        },
        .Array => |array_info| {
            const child = array_info.child;
            var array: T = undefined;
            for (&array) |*item| {
                if (child == u8) {
                     item.* = std.crypto.random.intRangeAtMost(u8, 65, 122);
                }else {
                    item.* = generateField(array_info.child);
                }
            }
            return array;
        },
        else => @compileError("Type '" ++ @typeName(T) ++ "' not supported "),
    }
}
