/// swap_strings.zig — Read two strings, print them swapped (Zig 0.16.0)
///
/// Compile:  zig build-exe swap_strings.zig
/// Run:      ./swap_strings
/// Or:       zig run swap_strings.zig

const std = @import("std");
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // ── stdout prompt (flush before reading stdin) ────────────────────────
    var out_buf: [256]u8 = undefined;
    var writer = std.Io.File.Writer.init(std.Io.File.stdout(), io, &out_buf);
    defer writer.flush() catch {};

    try writer.interface.print("Enter 2 strings: ", .{});
    try writer.flush();

    // ── stdin reader ──────────────────────────────────────────────────────
    var in_buf: [4096]u8 = undefined;
    var file_reader = std.Io.File.stdin().reader(io, &in_buf);
    const r = &file_reader.interface;

    const raw_line = r.takeDelimiterExclusive('\n') catch |err| switch (err) {
        error.EndOfStream   => { print("No input received.\n", .{}); return; },
        error.StreamTooLong => { print("Input too long.\n",     .{}); return; },
        error.ReadFailed    => { print("Failed to read stdin.\n", .{}); return; },
    };

    // Trim '\r' for Windows \r\n line endings
    const line = std.mem.trimEnd(u8, raw_line, "\r");

    // ── split on the first space ──────────────────────────────────────────
    var it = std.mem.splitScalar(u8, line, ' ');

    const first  = it.next() orelse {
        print("Please enter two strings separated by a space.\n", .{});
        return;
    };
    const second = it.next() orelse {
        print("Only one string found. Please enter two strings separated by a space.\n", .{});
        return;
    };

    // ── print swapped ─────────────────────────────────────────────────────
    print("{s} {s}\n", .{ second, first });
}
