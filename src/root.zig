const std = @import("std");
const builtin = @import("builtin");

const Platform = switch (builtin.os.tag) {
    .macos => @import("platform/macos.zig"),
    .windows => @import("platform/windows.zig"),
    .linux => @import("platform/linux.zig"),
    else => @compileError("Unsupported platform"),
};

pub const Window = struct {
    handle: ?*anyopaque,

    pub fn init() !Window {
        const platform_window = try Platform.Window.init();
        return Window{ .handle = platform_window.handle };
    }
};

pub fn runEventLoop() !void {
    return Platform.runEventLoop();
}
