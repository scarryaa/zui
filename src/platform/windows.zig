const std = @import("std");
const c = @cImport({
    @cDefine("WIN32_LEAN_AND_MEAN", "1");
    @cInclude("Windows.h");
});

pub const Window = struct {
    handle: ?*anyopaque,

    pub fn init() !Window {
        const instance = c.GetModuleHandleA(0);
        const WHITE_BRUSH: c.HBRUSH = @ptrCast(@alignCast(c.GetStockObject(c.WHITE_BRUSH)));

        // Register window class
        var window_class = c.WNDCLASSEX;
        window_class.hInstance = @ptrCast(@alignCast(instance));
        window_class.lpszClassName = "My Window";
        window_class.lpfnWndProc = struct {
            fn wndProc(hWnd: c.HWND, uMsg: c.UINT, wParam: c.WPARAM, lParam: c.LPARAM) callconv(.C) c.LRESULT {
                return c.DefWindowProcA(hWnd, uMsg, wParam, lParam);
            }
        }.wndProc;
        window_class.style = c.CS_HREDRAW | c.CS_VREDRAW;
        window_class.hCursor = c.LoadCursorA(0, 32512);
        window_class.hbrBackground = WHITE_BRUSH;
        _ = c.RegisterClassExW(&window_class);

        const window = c.CreateWindowExA(0, "My Window", "", c.WS_OVERLAPPEDWINDOW, 0, 0, 800, 600, null, null, c.GetModuleHandle(null), null);
        _ = c.ShowWindow(window, 1);

        return Window{
            .handle = window,
        };
    }
};

pub fn runEventLoop() !void {
    var msg = c.MSG;
    var received_message = c.GetMessageA(&msg, null, 0, 0);
    while (received_message != 0) : (received_message = c.GetMessageA(&msg, null, 0, 0)) {
        _ = c.TranslateMessage(&msg);
        _ = c.DispatchMessageA(&msg);
    }
}
