const std = @import("std");
const ui = @import("ui_lib");

pub fn main() !void {
    _ = try ui.Window.init();
    try ui.runEventLoop();
}
