const std = @import("std");


// ascii mapping
const A = 65;
const z = 122;



pub fn generateField(random: std.rand.Random, comptime T: type) T {  
    const typeInfo = @typeInfo(T);
    switch (typeInfo) {
        .Int => {
            const len: comptime_int = if (T == u8) 4 else if (T == u32) 4 else 7;
            var boundaries: [len]T =  undefined;
            getBoundaries(T, &boundaries);
            if (random.float(f32) < 0.2) {
                return boundaries[random.intRangeAtMost(usize, 0, boundaries.len - 1)];
            } else {
                if (T == u8) {
                    return random.intRangeAtMost(T, A, z);
                } else if (T == u32) {
                    const max = std.math.pow(T, 10, 3);
                    return random.intRangeAtMost(T, 0, max);
                } else {
                    const min = -std.math.pow(T, 10, 3);
                    const max = std.math.pow(T, 10, 3);
                    return random.intRangeAtMost(T, min, max);
                }
            }
        },
        .Float => {
            const special_values = [_]T{ -std.math.inf(T), -1, -std.math.floatMin(T), 0, std.math.floatMin(T), 1, std.math.inf(T), std.math.nan(T) };
            if (random.float(f32) < 0.2) {
                return special_values[random.intRangeAtMost(usize, 0, special_values.len - 1)];
            } else {
                return random.float(T);
            }
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


fn getBoundaries(comptime T: type, slice: []T) void {
    if (T == u8) {
        var boundaries = [_]T{ A, A + 1, z - 1, z };
        @memcpy(slice, &boundaries);
    } else if (T == u32) {
        const max = std.math.pow(T, 10, 3);
        var boundaries = [_]T{ 0, 1, max - 1, max };
        @memcpy(slice, &boundaries);
    } else {
        const min = -std.math.pow(T, 10, 3);
        const max = std.math.pow(T, 10, 3);
        var boundaries = [_]T{ min, min + 1, -1 , 0, 1, max - 1, max};
        @memcpy(slice, &boundaries);
    }
}
