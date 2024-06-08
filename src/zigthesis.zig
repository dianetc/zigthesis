const std = @import("std");
const generate = @import("generate.zig");
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
            std.debug.print("{s:<30} \x1b[32m✓\x1b[0m\n", .{test_name});
            return;
        }
        var args: std.meta.ArgsTuple(@TypeOf(predicate)) = undefined;
        inline for (&args, predTypeInfo.params) |*arg, param| {
            arg.* = generate.generateField(random, param.type.?);
        }
        const result = @call(.auto, predicate, args);
        if (!result) {
            std.debug.print("{s:<30} \x1b[31m✗\x1b[0m at: {any}\n", .{ test_name, args });
            return;
        }
    }
}