const std = @import("std");
const c = @cImport({
    @cDefine("WIN32_LEAN_AND_MEAN", "1");
    @cInclude("windows.h");
});

pub const Window = struct {
    handle: ?c.HWND,

    pub fn init() !Window {
        const instance = c.GetModuleHandleA(null);
        const WHITE_BRUSH: c.HBRUSH = @ptrCast(c.GetStockObject(c.WHITE_BRUSH));

        // Register window class
        var window_class = std.mem.zeroes(c.WNDCLASSEXA);
        window_class.cbSize = @sizeOf(c.WNDCLASSEXA);
        window_class.hInstance = instance;
        window_class.lpszClassName = "MyWindow";
        window_class.lpfnWndProc = wndProc;
        window_class.style = c.CS_HREDRAW | c.CS_VREDRAW;
        window_class.hCursor = c.LoadCursorA(null, c.IDC_ARROW);
        window_class.hbrBackground = WHITE_BRUSH;

        if (c.RegisterClassExA(&window_class) == 0) {
            return error.RegisterClassFailed;
        }

        const window = c.CreateWindowExA(0, "MyWindow", "Window Title", c.WS_OVERLAPPEDWINDOW, c.CW_USEDEFAULT, c.CW_USEDEFAULT, 800, 600, null, null, instance, null);

        if (window == null) {
            return error.CreateWindowFailed;
        }

        _ = c.ShowWindow(window, c.SW_SHOW);
        _ = c.UpdateWindow(window);

        return Window{
            .handle = window,
        };
    }
};

fn wndProc(hwnd: c.HWND, msg: c.UINT, wp: c.WPARAM, lp: c.LPARAM) callconv(.C) c.LRESULT {
    return c.DefWindowProcA(hwnd, msg, wp, lp);
}

pub fn runEventLoop() !void {
    var msg: c.MSG = undefined;
    while (c.GetMessageA(&msg, null, 0, 0) > 0) {
        _ = c.TranslateMessage(&msg);
        _ = c.DispatchMessageA(&msg);
    }
}
