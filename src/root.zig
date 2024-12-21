const cocoa = @cImport({
    @cInclude("objc/runtime.h");
    @cInclude("objc/message.h");
});

const std = @import("std");
const builtin = @import("builtin");

const NSRect = extern struct {
    x: f64,
    y: f64,
    width: f64,
    height: f64,
};

// Helper functions for Objective-C runtime
fn objc_getClass(name: [*:0]const u8) ?*anyopaque {
    return cocoa.objc_getClass(name);
}

fn objc_msgSend(obj: ?*anyopaque, sel: cocoa.SEL) ?*anyopaque {
    const func: *const fn (?*anyopaque, cocoa.SEL) callconv(.C) ?*anyopaque = @ptrCast(&cocoa.objc_msgSend);
    return @call(.auto, func, .{ obj, sel });
}

fn objc_msgSend_str(obj: ?*anyopaque, sel: cocoa.SEL, arg: [*:0]const u8) ?*anyopaque {
    const func: *const fn (?*anyopaque, cocoa.SEL, [*:0]const u8) callconv(.C) ?*anyopaque = @ptrCast(&cocoa.objc_msgSend);
    return @call(.auto, func, .{ obj, sel, arg });
}

fn objc_msgSend_rect(obj: ?*anyopaque, sel: cocoa.SEL, frame: NSRect, style: c_ulong, backing: c_ulong, defer_: bool) ?*anyopaque {
    const func: *const fn (?*anyopaque, cocoa.SEL, NSRect, c_ulong, c_ulong, bool) callconv(.C) ?*anyopaque = @ptrCast(&cocoa.objc_msgSend);
    return @call(.auto, func, .{ obj, sel, frame, style, backing, defer_ });
}

fn objc_msgSend_bool(obj: ?*anyopaque, sel: cocoa.SEL, arg: bool) void {
    const func: *const fn (?*anyopaque, cocoa.SEL, bool) callconv(.C) void = @ptrCast(&cocoa.objc_msgSend);
    @call(.auto, func, .{ obj, sel, arg });
}

fn objc_msgSend_void_id(obj: ?*anyopaque, sel: cocoa.SEL, arg: ?*anyopaque) void {
    const func: *const fn (?*anyopaque, cocoa.SEL, ?*anyopaque) callconv(.C) void = @ptrCast(&cocoa.objc_msgSend);
    @call(.auto, func, .{ obj, sel, arg });
}

fn objc_msgSend_id(obj: ?*anyopaque, sel: cocoa.SEL, arg: ?*anyopaque) ?*anyopaque {
    const func: *const fn (?*anyopaque, cocoa.SEL, ?*anyopaque) callconv(.C) ?*anyopaque = @ptrCast(&cocoa.objc_msgSend);
    return @call(.auto, func, .{ obj, sel, arg });
}

fn objc_msgSend_init_window(obj: ?*anyopaque, sel: cocoa.SEL, frame: anytype, style: c_ulong, backing: c_ulong, defer_: bool) ?*anyopaque {
    const func: *const fn (?*anyopaque, cocoa.SEL, @TypeOf(frame), c_ulong, c_ulong, bool) callconv(.C) ?*anyopaque = @ptrCast(&cocoa.objc_msgSend);
    return @call(.auto, func, .{ obj, sel, frame, style, backing, defer_ });
}

// Constants
const NSWindowStyleMaskTitled: c_ulong = 1;
const NSWindowStyleMaskClosable: c_ulong = 2;
const NSWindowStyleMaskMiniaturizable: c_ulong = 4;
const NSWindowStyleMaskResizable: c_ulong = 8;
const NSBackingStoreBuffered: c_ulong = 2;

pub const Window = struct {
    handle: ?*anyopaque,

    pub fn init() !Window {
        // Platform-specific window creation
        switch (builtin.os.tag) {
            .windows => return initWindows(),
            .linux => return initLinux(),
            .macos => return initMacos(),
            else => @compileError("Unsupported platform"),
        }
    }

    fn initWindows() !Window {
        // Windows-specific implementation
        @compileError("Windows implementation not yet available");
    }

    fn initLinux() !Window {
        // Linux-specific implementation
        @compileError("Linux implementation not yet available");
    }

    fn initMacos() !Window {
        const NSThread = objc_getClass("NSThread") orelse return error.ClassNotFound;
        const isMainThread = cocoa.sel_registerName("isMainThread");
        const is_main = objc_msgSend(NSThread, isMainThread);
        if (is_main == null) {
            return error.NotMainThread;
        }

        // Get necessary classes
        const NSApplication = objc_getClass("NSApplication") orelse return error.ClassNotFound;
        const NSWindow = objc_getClass("NSWindow") orelse return error.ClassNotFound;
        const NSString = objc_getClass("NSString") orelse return error.ClassNotFound;

        // Get necessary selectors
        const sharedApplication = cocoa.sel_registerName("sharedApplication");
        const alloc = cocoa.sel_registerName("alloc");
        const initWithContentRect = cocoa.sel_registerName("initWithContentRect:styleMask:backing:defer:");
        const setTitle = cocoa.sel_registerName("setTitle:");
        const makeKeyAndOrderFront = cocoa.sel_registerName("makeKeyAndOrderFront:");
        const stringWithUTF8String = cocoa.sel_registerName("stringWithUTF8String:");
        const activateIgnoringOtherApps = cocoa.sel_registerName("activateIgnoringOtherApps:");

        // Create application instance
        const app = objc_msgSend(NSApplication, sharedApplication);

        // Create window
        const window_alloc = objc_msgSend(NSWindow, alloc);

        const frame = NSRect{
            .x = 100,
            .y = 100,
            .width = 800,
            .height = 600,
        };

        const style_mask = NSWindowStyleMaskTitled |
            NSWindowStyleMaskClosable |
            NSWindowStyleMaskMiniaturizable |
            NSWindowStyleMaskResizable;

        const window = objc_msgSend_rect(window_alloc, initWithContentRect, frame, style_mask, NSBackingStoreBuffered, false);

        const title = objc_msgSend_str(NSString, stringWithUTF8String, "My Window");
        _ = objc_msgSend_id(window, setTitle, title);

        // Show window
        objc_msgSend_void_id(window, makeKeyAndOrderFront, null);

        // Activate application
        objc_msgSend_bool(app, activateIgnoringOtherApps, false);

        return Window{
            .handle = window,
        };
    }
};

pub fn runEventLoop() !void {
    switch (builtin.os.tag) {
        .windows => return runEventLoopWindows(),
        .linux => return runEventLoopLinux(),
        .macos => return runEventLoopMacos(),
        else => @compileError("Unsupported platform"),
    }
}

fn runEventLoopWindows() !void {
    @compileError("Windows implementation not yet available");
}

fn runEventLoopLinux() !void {
    @compileError("Linux implementation not yet available");
}

fn runEventLoopMacos() !void {
    const NSApplication = objc_getClass("NSApplication") orelse return error.ClassNotFound;
    const sharedApplication = cocoa.sel_registerName("sharedApplication");
    const run = cocoa.sel_registerName("run");

    const app = objc_msgSend(NSApplication, sharedApplication);
    _ = objc_msgSend(app, run);
}
