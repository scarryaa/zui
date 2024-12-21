const std = @import("std");
const windows = @import("std").os.windows;

// External function declarations
pub extern "kernel32" fn GetModuleHandleW(
    lpModuleName: ?[*:0]const u16,
) callconv(windows.WINAPI) ?windows.HANDLE;

pub extern "gdi32" fn GetStockObject(index: c_int) callconv(.C) ?HGDIOBJ;
pub extern "user32" fn LoadCursorW(hInstance: ?windows.HANDLE, lpCursorName: [*:0]const u16) callconv(windows.WINAPI) ?HCURSOR;
pub extern "user32" fn RegisterClassExW(
    lpWndClass: *const WNDCLASSEXW,
) callconv(windows.WINAPI) u16;
pub extern "user32" fn CreateWindowExW(
    dwExStyle: windows.DWORD,
    lpClassName: [*:0]const u16,
    lpWindowName: [*:0]const u16,
    dwStyle: windows.DWORD,
    X: c_int,
    Y: c_int,
    nWidth: c_int,
    nHeight: c_int,
    hWndParent: ?windows.HWND,
    hMenu: ?windows.HMENU,
    hInstance: ?windows.HINSTANCE,
    lpParam: ?*anyopaque,
) callconv(windows.WINAPI) ?windows.HWND;
pub extern "user32" fn DefWindowProcW(
    hWnd: windows.HWND,
    Msg: windows.UINT,
    wParam: windows.WPARAM,
    lParam: windows.LPARAM,
) callconv(windows.WINAPI) windows.LRESULT;
pub extern "user32" fn ShowWindow(
    hWnd: windows.HWND,
    nCmdShow: i32,
) callconv(windows.WINAPI) windows.BOOL;
pub extern "user32" fn UpdateWindow(
    hWnd: windows.HWND,
) callconv(windows.WINAPI) windows.BOOL;
pub extern "user32" fn GetMessageW(
    lpMsg: *MSG,
    hWnd: ?windows.HWND,
    wMsgFilterMin: windows.UINT,
    wMsgFilterMax: windows.UINT,
) callconv(windows.WINAPI) windows.BOOL;
pub extern "user32" fn TranslateMessage(
    lpMsg: *const MSG,
) callconv(windows.WINAPI) windows.BOOL;
pub extern "user32" fn DispatchMessageW(
    lpMsg: *const MSG,
) callconv(windows.WINAPI) windows.LRESULT;
pub extern "user32" fn LoadIconW(
    hInstance: ?windows.HINSTANCE,
    lpIconName: [*:0]const u16,
) callconv(windows.WINAPI) ?windows.HICON;

// Type definitions
pub const HGDIOBJ = *anyopaque;
pub const HCURSOR = *anyopaque;
pub const HBRUSH = *anyopaque;

// Constants
pub const MSG = extern struct {
    hwnd: windows.HWND,
    message: windows.UINT,
    wParam: windows.WPARAM,
    lParam: windows.LPARAM,
    time: windows.DWORD,
    pt: windows.POINT,
};

pub const CW_USEDEFAULT: i32 = @bitCast(@as(u32, 0x80000000));
pub const SW_SHOW: i32 = 5;
pub const IDI_APPLICATION: u16 = 32512;
pub const WS_OVERLAPPED = 0x00000000;
pub const WS_CAPTION = 0x00C00000;
pub const WS_SYSMENU = 0x00080000;
pub const WS_THICKFRAME = 0x00040000;
pub const WS_MINIMIZEBOX = 0x00020000;
pub const WS_MAXIMIZEBOX = 0x00010000;
pub const WS_OVERLAPPEDWINDOW = (WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU |
    WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX);

pub const WHITE_BRUSH = 0;
pub const IDC_ARROW = 32512;
pub const CS_HREDRAW = 0x0002;
pub const CS_VREDRAW = 0x0001;

pub const WNDPROC = *const fn (
    hwnd: windows.HWND,
    uMsg: windows.UINT,
    wParam: windows.WPARAM,
    lParam: windows.LPARAM,
) callconv(windows.WINAPI) windows.LRESULT;

pub const WNDCLASSEXW = extern struct {
    cbSize: windows.UINT,
    style: windows.UINT,
    lpfnWndProc: WNDPROC,
    cbClsExtra: c_int,
    cbWndExtra: c_int,
    hInstance: windows.HINSTANCE,
    hIcon: windows.HICON,
    hCursor: windows.HCURSOR,
    hbrBackground: HBRUSH,
    lpszMenuName: ?[*:0]const u16,
    lpszClassName: [*:0]const u16,
    hIconSm: windows.HICON,
};

pub const Window = struct {
    handle: ?windows.HWND,

    pub fn init() !Window {
        const instance = GetModuleHandleW(null);

        var window_class = std.mem.zeroes(WNDCLASSEXW);
        window_class.cbSize = @sizeOf(WNDCLASSEXW);
        window_class.hInstance = @ptrCast(instance.?);
        window_class.lpszClassName = &[_:0]u16{ 'M', 'y', 'W', 'i', 'n', 'd', 'o', 'w' };
        window_class.lpfnWndProc = wndProc;
        window_class.style = CS_HREDRAW | CS_VREDRAW;
        const icon = LoadIconW(null, MAKEINTRESOURCEW(IDI_APPLICATION)) orelse return error.LoadIconFailed;
        window_class.hIcon = @ptrCast(icon);
        window_class.hIconSm = @ptrCast(icon);

        const cursor = LoadCursorW(null, MAKEINTRESOURCEW(IDC_ARROW)) orelse
            return error.LoadCursorFailed;
        window_class.hCursor = @ptrCast(cursor);

        const brush = GetStockObject(WHITE_BRUSH) orelse
            return error.GetStockObjectFailed;
        window_class.hbrBackground = @ptrCast(brush);

        if (RegisterClassExW(&window_class) == 0) {
            return error.RegisterClassFailed;
        }

        const window = CreateWindowExW(0, window_class.lpszClassName, &[_:0]u16{ 'W', 'i', 'n', 'd', 'o', 'w', ' ', 'T', 'i', 't', 'l', 'e' }, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 800, 600, null, null, @ptrCast(instance.?), null);

        if (window == null) {
            return error.CreateWindowFailed;
        }

        _ = ShowWindow(window.?, SW_SHOW);
        _ = UpdateWindow(window.?);

        return Window{
            .handle = window,
        };
    }
};

fn wndProc(hwnd: windows.HWND, msg: windows.UINT, wp: windows.WPARAM, lp: windows.LPARAM) callconv(windows.WINAPI) windows.LRESULT {
    return DefWindowProcW(hwnd, msg, wp, lp);
}

fn MAKEINTRESOURCEW(i: u16) [*:0]const u16 {
    return @ptrFromInt(@as(usize, i));
}

pub fn runEventLoop() !void {
    var msg: MSG = undefined;
    while (GetMessageW(&msg, null, 0, 0) > 0) {
        _ = TranslateMessage(&msg);
        _ = DispatchMessageW(&msg);
    }
}
