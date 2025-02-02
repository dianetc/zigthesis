const std = @import("std");

// ascii mapping
const A = 65;
const z = 122;

pub fn generateField(alloc: std.mem.Allocator, random: std.rand.Random, comptime T: type) std.mem.Allocator.Error!T {
    const typeInfo = @typeInfo(T);
    switch (typeInfo) {
        .Bool => {
            return random.boolean();
        },
        .Int => {
            const len: comptime_int = if (typeInfo.Int.signedness == .signed) 7 else 4;
            var boundaries: [len]T = undefined;
            getBoundaries(T, &boundaries);
            if (random.float(f32) < 0.2) {
                return boundaries[random.intRangeAtMost(usize, 0, boundaries.len - 1)];
            } else {
                if (T == u8) {
                    return random.intRangeAtMost(T, A, z);
                } else if (T == i8) {
                    return random.intRangeAtMost(T, std.math.minInt(T), std.math.maxInt(T));
                } else if (T == u32) {
                    const max = comptime std.math.pow(T, 10, 3);
                    return random.intRangeAtMost(T, 0, max);
                } else if (typeInfo.Int.signedness == .unsigned) {
                    const max = comptime std.math.maxInt(T);
                    return random.intRangeAtMost(T, 0, max);
                } else {
                    const min = comptime -std.math.pow(T, 10, 3);
                    const max = comptime std.math.pow(T, 10, 3);
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
                item.* = try generateField(alloc, random, array_info.child);
            }
            return array;
        },
        .Vector => |vector_info| {
            const elementType = vector_info.child;
            const elementCount = vector_info.len;
            var vector: T = undefined;
            var i: usize = 0;
            while (i < elementCount) : (i += 1) {
                vector[i] = try generateField(alloc, random, elementType);
            }
            const vec: @Vector(elementCount, elementType) = vector;
            return vec;
        },
        .Struct => {
            var instance: T = undefined;
            const structInfo = typeInfo.Struct;
            inline for (structInfo.fields) |field| {
                @field(instance, field.name) = try generateField(alloc, random, field.type);
            }
            return instance;
        },
        .Union => {
            var instance: T = undefined;
            const unionInfo = typeInfo.Union;
            const field_index = random.intRangeAtMost(usize, 0, unionInfo.fields.len - 1);
            switch (field_index) {
                inline 0...unionInfo.fields.len - 1 => |i| {
                    instance = @unionInit(T, unionInfo.fields[i].name, try generateField(alloc, random, unionInfo.fields[i].type));
                },
                else => unreachable,
            }
            return instance;
        },
        .Void => {
            return {};
        },
        .Optional => {
            if (random.float(f32) < 0.5) {
                return null;
            } else {
                return try generateField(alloc, random, typeInfo.Optional.child);
            }
        },
        .Pointer => {
            switch (typeInfo.Pointer.size) {
                .One => {
                    const one = try alloc.create(typeInfo.Pointer.child);
                    errdefer alloc.destroy(one);
                    one.* = try generateField(alloc, random, typeInfo.Pointer.child);
                    return one;
                },
                .Slice => {
                    const len = random.intRangeAtMost(usize, 0, 10);
                    var array = try alloc.alloc(typeInfo.Pointer.child, len);
                    errdefer alloc.free(array);
                    for (0..array.len) |i| {
                        array[i] = try generateField(alloc, random, typeInfo.Pointer.child);
                    }
                    return array[0..array.len];
                },
                else => {
                    @compileError("Pointer type '" ++ @tagName(typeInfo.Pointer.size) ++ "' not supported ");
                },
            }
        },
        else => @compileError("Type '" ++ @typeName(T) ++ "' not supported "),
    }
}

fn getBoundaries(comptime T: type, slice: []T) void {
    const typeInfo = @typeInfo(T);
    if (T == u8) {
        var boundaries = [_]T{ A, A + 1, z - 1, z };
        @memcpy(slice, &boundaries);
    } else if (T == i8) {
        const min = comptime std.math.minInt(T);
        const max =  comptime std.math.maxInt(T);
        var boundaries = [_]T{ min, min + 1, -1, 0, 1, max - 1, max };
        @memcpy(slice, &boundaries);
    } else if (T == u32) {
        const max = comptime std.math.pow(T, 10, 3);
        var boundaries = [_]T{ 0, 1, max - 1, max };
        @memcpy(slice, &boundaries);
    } else if (typeInfo == .Int and typeInfo.Int.signedness == .unsigned) {
        const max = comptime std.math.maxInt(T);
        var boundaries = [_]T{ 0, 1, max - 1, max };
        @memcpy(slice, &boundaries);
    } else {
        const min = comptime -std.math.pow(T, 10, 3);
        const max = comptime std.math.pow(T, 10, 3);
        var boundaries = [_]T{ min, min + 1, -1, 0, 1, max - 1, max };
        @memcpy(slice, &boundaries);
    }
}
