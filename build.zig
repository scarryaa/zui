const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "ui_lib",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add Objective-C support
    lib.linkLibC();
    lib.linkFramework("Foundation");
    lib.linkFramework("Cocoa");
    lib.linkFramework("AppKit");

    // Add SDK paths
    const sdk_base = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk";
    lib.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sdk_base, "usr/include" }) });
    lib.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sdk_base, "usr/include/objc" }) });
    lib.addSystemFrameworkPath(.{ .cwd_relative = b.pathJoin(&.{ sdk_base, "System/Library/Frameworks" }) });

    // Enable Objective-C runtime
    lib.linkSystemLibrary("objc");

    switch (target.result.os.tag) {
        .windows => {
            lib.linkSystemLibrary("user32");
            lib.linkSystemLibrary("gdi32");
            lib.linkSystemLibrary("kernel32");
        },
        .linux => {
            lib.linkSystemLibrary("gtk+-3.0");
            lib.linkSystemLibrary("x11");
        },
        .macos => {},
        else => @panic("Unsupported platform"),
    }

    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_main_tests = b.addRunArtifact(main_tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);

    const example = b.addExecutable(.{
        .name = "example",
        .root_source_file = b.path("examples/basic.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add same Objective-C support to the example
    example.linkLibC();
    example.linkFramework("Foundation");
    example.linkFramework("Cocoa");
    example.linkFramework("AppKit");
    example.linkSystemLibrary("objc");
    example.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sdk_base, "usr/include" }) });
    example.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sdk_base, "usr/include/objc" }) });
    example.addSystemFrameworkPath(.{ .cwd_relative = b.pathJoin(&.{ sdk_base, "System/Library/Frameworks" }) });

    // Create module
    const lib_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
    });
    example.root_module.addImport("ui_lib", lib_module);

    const run_example = b.addRunArtifact(example);
    const run_step = b.step("run-example", "Run example application");
    run_step.dependOn(&run_example.step);
}
