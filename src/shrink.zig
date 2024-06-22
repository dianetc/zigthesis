const std = @import("std");

pub fn shrink(comptime T: type, value: T, predicate: anytype, args: anytype) T {
    return switch (@typeInfo(T)) {
        .Int => shrinkInt(T, value, predicate, args),
        .Float => shrinkFloat(T, value, predicate, args),
        .Array => value, //shrinkArray(T, value, predicate, args),
        .Struct => value, //shrinkStruct(T, value, predicate, args),
        else => value,
    };
}

fn shrinkInt(comptime T: type, value: T, predicate: anytype, args: anytype) T {
    if (T == u8){ return value; }
    var current = value;
    const targets = [_]T{0, 1, -1, @divTrunc(value, 2), @divTrunc(-value, 2)};

    for (targets) |target| {
        if (target != current and !predicate(target, args)) {
            return target;
        }
    }

    while (current != 0) {
        const next = @divTrunc(current, 2);
        if (next != current and !predicate(next, args)) {
            return next;
        }
        current = next;
    }

    return value;
}

fn shrinkFloat(comptime T: type, value: T, predicate: anytype, args: anytype) T {
    var current = value;
    const targets = [_]T{0, 1, -1, @divTrunc(value, 2), @divTrunc(-value, 2)};

    for (targets) |target| {
        if (target != current and !predicate(target, args)) {
            return target;
        }
    }

    while (current != 0) {
        const next = @divTrunc(current, 2);
        if (next != current and !predicate(next, args)) {
            return next;
        }
        current = next;
    }

    return value;
}

fn shrinkArray(comptime T: type, value: T, predicate: anytype, args: anytype) T {
    const info = @typeInfo(T).Array;
    // Try shrinking individual elements
    var i: usize = 0;
    while (i < info.len) : (i += 1) {
        var shrunk = value;
        const curr = i;
        shrunk[i] = shrink(info.child, value[i], struct {
            fn inner(v: info.child, a: @TypeOf(args)) bool {
                var temp = value;
                temp[curr] = v;
                return predicate(temp, a);
            }
        }.inner, args);
        if (!predicate(shrunk, args)) {
            return shrunk;
        }
    }
    return value;
}

//fn shrinkStruct(comptime T: type, value: T, predicate: anytype, args: anytype) T {
//    var current = value;
//    const info = @typeInfo(T).Struct;
//    inline for (info.fields) |field| {
//        var shrunk = current;
//        @field(shrunk, field.name) = shrink(field.type, @field(current, field.name), struct {
//            fn inner(v: field.type, a: @TypeOf(args)) bool {
//                var temp = current;
//                @field(temp, field.name) = v;
//                return predicate(temp, a);
//            }
//        }.inner, args);
//       if (!predicate(shrunk, args)) {
//            return shrunk;
//        }
//    }
//    return current;
//}