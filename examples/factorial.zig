/// factorial.zig — Read n from stdin, compute n!, print the result.
///
/// Compile:  zig build-exe factorial.zig
/// Run:      ./factorial

const std = @import("std");
const print = std.debug.print;

// 11! is still u64-safe, but the domain is single-digit input.
const CEILING: u32 = 10;

/// Compute n! iteratively.
/// Caller must ensure n ≤ CEILING; no overflow check is performed here.
fn factorial(n: u32) u64 {
    var product: u64 = 1;
    var step: u32 = 2;
    while (step <= n) : (step += 1) {
        product *= step;
    }
    return product;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    var out_buf: [64]u8 = undefined;
    var writer = std.Io.File.Writer.init(std.Io.File.stdout(), io, &out_buf);
    // stdout flush errors on exit are not recoverable; ignore intentionally.
    defer writer.flush() catch {};

    try writer.interface.print("Enter a number (1–{d}): ", .{CEILING});
    // Flush before blocking on stdin so the prompt appears before the cursor.
    try writer.flush();

    var in_buf: [64]u8 = undefined;
    var file_reader = std.Io.File.stdin().reader(io, &in_buf);
    const r = &file_reader.interface;

    const raw_line = r.takeDelimiterExclusive('\n') catch |err| switch (err) {
        error.EndOfStream   => { print("No input received.\n",   .{}); return; },
        error.StreamTooLong => { print("Input too long.\n",      .{}); return; },
        error.ReadFailed    => { print("stdin read failed.\n",   .{}); return; },
    };

    // Windows line endings carry \r before \n; strip it so parseInt does not fail.
    const line = std.mem.trimEnd(u8, raw_line, "\r");

    const input_n = std.fmt.parseInt(u32, line, 10) catch {
        print("'{s}' is not a valid positive integer.\n", .{line});
        return;
    };

    if (input_n == 0) {
        print("n must be at least 1.\n", .{});
        return;
    }

    // Clamp inputs above CEILING; factorial's doc comment documents the safe range.
    const n: u32 = if (input_n > CEILING) blk: {
        print("Input {d} exceeds ceiling {d}; using {d}.\n",
              .{ input_n, CEILING, CEILING });
        break :blk CEILING;
    } else input_n;

    print("{d}! = {d}\n", .{ n, factorial(n) });
}
