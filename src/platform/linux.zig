const xlib = @cImport({
    @cInclude("X11/Xlib.h");
});

pub const Window = struct {
    pub fn init() !Window {
        @compileError("Linux not implemented yet");
    }
};

pub fn runEventLoop() !void {
    @compileError("Linux not implemented yet");
}
