const xlib = @cImport({
    @cInclude("X11/Xlib.h");
});

pub const Window = struct {
    display: *xlib.Display,
    screen: c_int,
    root: xlib.Window,

    pub fn init() !Window {
        const display = xlib.XOpenDisplay(null) orelse @panic("unable to create window");
        const screen = xlib.XDefaultScreen(display);
        const root = xlib.XRootWindow(display, screen);

        _ = xlib.XftFontOpenName(display, screen, "Ubuntu Sans".ptr) orelse @panic("could not load font");

        const cursor = xlib.XCreateFontCursor(display, 2);
        var windowAttributes: xlib.XSetWindowAttributes = undefined;
        windowAttributes.event_mask = xlib.SubstructureNotifyMask |
            xlib.SubstructureRedirectMask |
            xlib.KeyPressMask |
            xlib.EnterWindowMask |
            xlib.FocusChangeMask |
            xlib.PropertyChangeMask |
            xlib.PointerMotionMask |
            xlib.NoEventMask;
        windowAttributes.cursor = cursor;

        _ = xlib.XChangeWindowAttributes(display, root, xlib.CWEventMask | xlib.CWCursor, &windowAttributes);
        _ = xlib.XSelectInput(display, root, windowAttributes.event_mask);
        _ = xlib.XSync(display, 0);

        return Window{
            .display = display,
            .screen = screen,
            .root = root,
        };
    }

    pub fn deinit(self: *Window) void {
        _ = xlib.XCloseDisplay(self.display);
    }
};

pub fn runEventLoop(window: *Window) !void {
    var event: xlib.XEvent = undefined;

    while (true) {
        _ = xlib.XNextEvent(window.display, &event);

        switch (event.type) {
            xlib.KeyPress => {
                // Handle key press
            },
            xlib.EnterNotify => {
                // Handle enter notify
            },
            // Add other event handlers
            else => {},
        }
    }
}
