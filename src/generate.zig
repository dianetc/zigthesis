const std = @import("std");

const A = 65;
const z = 122;

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
            if (T == u8){
                return std.crypto.random.intRangeAtMost(T, A, z);
            } else {
                return std.crypto.random.intRangeAtMost(T, std.math.pow(i32, -10, 3), std.math.pow(i32, 10, 3));
            }
        },
        .Float => {
            return std.crypto.random.float(T);
        },
        .Array => |array_info| {
            var array: T = undefined;
            for (&array) |*item| {
                    item.* = generateField(array_info.child);
            }
            return array;
        },
        else => @compileError("Type '" ++ @typeName(T) ++ "' not supported "),
    }
}
