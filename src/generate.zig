const std = @import("std");
const decl = @import("decl/utils.zig");


// ascii mapping
const A = 65;
const z = 122;


pub fn generateField(random: std.rand.Random, comptime T: type) T {  
    const typeInfo = @typeInfo(T);
    switch (typeInfo) {
        .Int => {
            if (T == u8){
                return random.intRangeAtMost(T, A, z);
            } else if (T == u32) {
                return random.intRangeAtMost(T, 0, std.math.pow(i32, 10, 3));
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
        .Vector => |vector_info| {
            const elementType = vector_info.child;
            const elementCount = vector_info.len;
            var vector: T = undefined;
            var i: usize = 0;
            while (i < elementCount) : (i += 1) {
                vector[i] = generateField(random, elementType);
            }
            const vec: @Vector(elementCount, elementType) = vector;
            return vec;
        },
        .Struct => {
            var instance: T = undefined;
            const structInfo = typeInfo.Struct;
            inline for (structInfo.fields) |field| {
                @field(instance, field.name) = generateField(random, field.type);
            }
            return instance;
        },
        else => @compileError("Type '" ++ @typeName(T) ++ "' not supported "),
    }
}
