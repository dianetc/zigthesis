const std = @import("std");
const generate = @import("generate.zig");
const shrink = @import("shrink.zig");

comptime {
    if (@import("builtin").is_test) {
        _ = @import("shrink.zig");
    }}
 
pub const Error = error{
    Failed,
};

fn defaultOnError(seed: u64, test_name: []const u8, args : anytype) Error!void {
    std.debug.print("{s:<30} failed for {any} with seed {d}\n", .{ test_name, args, seed});
}

/// A function for onError that will fail the test.
pub fn failOnError(seed: u64, test_name: []const u8, args : anytype) Error!void {
    try defaultOnError(seed, test_name, args);
    return error.Failed;
}

/// Config for falsification.
/// max_duration_ms: The maximum duration of the test in milliseconds.
/// max_iterations: The maximum number of iterations to run.
/// The test will complete when it's performed max_iterations or max_duration_ms has passed.
pub const Config = struct {
    max_duration_ms: u64 = 5 * 1000,
    max_iterations: u64 = std.math.maxInt(u64),
    seed: ?u64 = null,
    /// The function to call if the test fails.  It should return an error if the test is considered failed.
    onError: fn (seed: u64, test_name: []const u8, args : anytype) Error!void = defaultOnError,
};

pub fn falsifyWith(predicate: anytype, test_name: []const u8, config: Config) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const predTypeInfo = @typeInfo(@TypeOf(predicate)).@"fn";
    const start_time = std.time.milliTimestamp();
    var seed: u64 = undefined;
    var prng = blk: {
        if (config.seed) |s| {
            seed = s;
        } else {
            try std.posix.getrandom(std.mem.asBytes(&seed));
        }
        break :blk std.Random.DefaultPrng.init(seed);
    };
    const random = prng.random();

    for (0..config.max_iterations) |_| {
        const current_time = std.time.milliTimestamp();
        if (current_time - start_time >= config.max_duration_ms) {
            return;
        }
        var args: std.meta.ArgsTuple(@TypeOf(predicate)) = undefined;
        inline for (&args, predTypeInfo.params) |*arg, param| {
            arg.* = try generate.generateField(arena.allocator(), random, param.type.?);
        }
        const result = @call(.auto, predicate, args);
        if (!result) {
            args = shrinkArgs(predicate, args);
            return config.onError(seed,test_name, args);
        }
    }
}

pub fn falsify(predicate: anytype, test_name: []const u8) !void {
    return falsifyWith(predicate, test_name, .{});
}

fn shrinkArgs(predicate: anytype, args: std.meta.ArgsTuple(@TypeOf(predicate))) std.meta.ArgsTuple(@TypeOf(predicate)) {
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