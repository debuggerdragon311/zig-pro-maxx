/// adder.zig — Read two integers from stdin and print their sum (Zig 0.16.0)
///
/// Compile:  zig build-exe adder.zig
/// Run:      ./adder
/// Or:       zig run adder.zig

const std = @import("std");
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // ── stdout writer ─────────────────────────────────────────────────────
    var out_buf: [256]u8 = undefined;
    var writer = std.Io.File.Writer.init(std.Io.File.stdout(), io, &out_buf);
    defer writer.flush() catch {};

    // ── stdin reader ──────────────────────────────────────────────────────
    var in_buf: [4096]u8 = undefined;
    var file_reader = std.Io.File.stdin().reader(io, &in_buf);
    const r = &file_reader.interface;

    // ── read first number ─────────────────────────────────────────────────
    try writer.interface.print("Enter first number : ", .{});
    try writer.flush();

    // takeDelimiterInclusive: returns slice WITH the '\n' and CONSUMES it,
    // so the next read starts cleanly on a fresh line.
    // (takeDelimiterExclusive leaves '\n' buffered, causing the second read
    // to return "" immediately — that was the original bug.)
    const raw_a = r.takeDelimiterInclusive('\n') catch |err| {
        print("Error reading first number: {s}\n", .{@errorName(err)});
        return;
    };
    const line_a = std.mem.trimEnd(u8, raw_a, "\r\n");

    const num_a = std.fmt.parseInt(i64, line_a, 10) catch {
        print("'{s}' is not a valid integer.\n", .{line_a});
        return;
    };

    // ── read second number ────────────────────────────────────────────────
    try writer.interface.print("Enter second number: ", .{});
    try writer.flush();

    const raw_b = r.takeDelimiterInclusive('\n') catch |err| {
        print("Error reading second number: {s}\n", .{@errorName(err)});
        return;
    };
    const line_b = std.mem.trimEnd(u8, raw_b, "\r\n");

    const num_b = std.fmt.parseInt(i64, line_b, 10) catch {
        print("'{s}' is not a valid integer.\n", .{line_b});
        return;
    };

    // ── compute and print result ──────────────────────────────────────────
    // std.math.add catches overflow instead of silent wrapping.
    const sum = std.math.add(i64, num_a, num_b) catch {
        print("Overflow: {d} + {d} does not fit in i64.\n", .{ num_a, num_b });
        return;
    };

    print("\n{d} + {d} = {d}\n", .{ num_a, num_b, sum });
}
