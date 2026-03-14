const std = @import("std");
const avr_board = @import("examples/build_support.zig");

pub fn build(b: *std.Build) void {
    const optimize: std.builtin.OptimizeMode = .ReleaseSafe;
    const board = avr_board.resolveBoard(b);
    const spec = avr_board.spec(board);

    _ = b.addModule("avr_zig", .{
        .root_source_file = b.path("src/root.zig"),
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "avr_zig",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = b.resolveTargetQuery(spec.target_query),
            .optimize = optimize,
        }),
    });
    lib.bundle_compiler_rt = false;
    lib.bundle_ubsan_rt = false;

    b.installArtifact(lib);

    const check = b.step("check", "Build the AVR Zig library archive");
    check.dependOn(b.getInstallStep());
}
