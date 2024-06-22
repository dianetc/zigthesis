const std = @import("std");
const generate = @import("generate.zig");
const shrink = @import("shrink.zig");
const MAX_DURATION_MS: u64 = 5 * 1000;

pub fn falsify(predicate: anytype, test_name: []const u8) !void {
    const predTypeInfo = @typeInfo(@TypeOf(predicate)).Fn;
    const start_time = std.time.milliTimestamp();
    var prng = blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk std.rand.DefaultPrng.init(seed);
    };
    const random = prng.random();

    while (true) {
        const current_time = std.time.milliTimestamp();
        if (current_time - start_time >= MAX_DURATION_MS) {
            return;
        }
        var args: std.meta.ArgsTuple(@TypeOf(predicate)) = undefined;
        inline for (&args, predTypeInfo.params) |*arg, param| {
            arg.* = generate.generateField(random, param.type.?);
        }
        const result = @call(.auto, predicate, args);
        if (!result) {
            args = shrinkArgs(predicate, args);
            std.debug.print("{s:<30} failed for {any}\n", .{ test_name, args });
            return;
        }
    }
}

fn shrinkArgs(predicate: anytype, args: std.meta.ArgsTuple(@TypeOf(predicate))) std.meta.ArgsTuple(@TypeOf(predicate)) {
    //const predTypeInfo = @typeInfo(@TypeOf(predicate)).Fn;
    var shrunk_args = args; 
    inline for (&shrunk_args, 0..) |*arg, i| {
        arg.* = shrink.shrink(@TypeOf(arg.*), arg.*, struct {
            fn inner(new_value: @TypeOf(arg.*), current_args: std.meta.ArgsTuple(@TypeOf(predicate))) bool {
                var test_args = current_args;
                @field(test_args, std.meta.fieldNames(std.meta.ArgsTuple(@TypeOf(predicate)))[i]) = new_value;
                return @call(.auto, predicate, test_args);
            }
        }.inner, shrunk_args);
    } 
    return shrunk_args;
}