
test "safeFloatOperation" {
    const std = @import("std");
    const utils = @import("../src/utils.zig");

    const add = fn (a: f32, b: f32) f32 {
        return a + b;
    };

    const result = utils.safeFloatOperation(i32, 1, 2.0, add);
    std.testing.expectEqual(result, 3.0);
}
