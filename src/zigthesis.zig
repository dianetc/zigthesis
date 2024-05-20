const std = @import("std");
const generate = @import("generate.zig");

const MAX_DURATION_MS: u64 = 10 * 1000;

pub fn falsify(predicate: anytype, test_name: []const u8) void {
    const gen = generate.Generator(@TypeOf(predicate));
    const start_time = std.time.milliTimestamp();
    while (true) {
        const current_time = std.time.milliTimestamp();
        if (current_time - start_time >= MAX_DURATION_MS) {
            std.debug.print("{s} succeeded.\n", .{test_name});
            return;
        }

        const args = gen.generate();
        const result = predicate(args);
        if (!result) {
            std.debug.print("{s} failed with case: {any}\n", .{ test_name, args });
            return;
        }
    }
}
