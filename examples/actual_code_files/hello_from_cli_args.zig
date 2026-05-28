const std = @import("std");

// init.args is std.process.Args — a wrapper around the OS argv vector.
// You must call .iterate() first to get an Args.Iterator, then .next() on that.
pub fn main(init: std.process.Init.Minimal) void {
    var it = init.args.iterate();

    const prog = it.next() orelse "program"; // argv[0]: program name
    const name = it.next() orelse {
        std.debug.print("Usage: {s} <your name>\n", .{prog});
        return;
    };

    std.debug.print("Hello, {s}!\n", .{name});
}
