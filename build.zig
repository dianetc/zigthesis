const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zigthesis_module = b.addModule("zigthesis", .{
        .root_source_file = b.path("src/zigthesis.zig"),
    });

    const utils_module = b.addModule("utils", .{
        .root_source_file = b.path("src/utils.zig"),
    });

    const exe = b.addExecutable(.{
        .name = "zigthesis",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("zigthesis", zigthesis_module);
    exe.root_module.addImport("utils", utils_module);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const test_step = b.step("test", "Run all tests");

    const tests = b.addTest(.{
        .root_source_file = b.path("tests/tests.zig"),
        .target = target,
        .optimize = optimize,
    });

    tests.root_module.addImport("zigthesis", zigthesis_module);
    tests.root_module.addImport("utils", utils_module);

    const internal_tests = b.addTest(.{
        .root_source_file = b.path("src/zigthesis.zig"),
        .target = target,
        .optimize = optimize,
    });

    test_step.dependOn(&b.addRunArtifact(tests).step);
    test_step.dependOn(&b.addRunArtifact(internal_tests).step);
}
