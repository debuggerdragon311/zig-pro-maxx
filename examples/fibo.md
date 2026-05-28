```zig
/// fibonacci.zig - Print the first N Fibonacci numbers (Zig 0.16.0)
///
/// Compile:  zig build-exe fibonacci.zig
/// Run:      ./fibonacci
/// Or:       zig run fibonacci.zig

const std = @import("std");
const print = std.debug.print;

// F(93) is the last Fibonacci number that fits in u64.
const MAX_N: u32 = 93;

/// Compute and print the first `count` Fibonacci numbers iteratively.
fn printFibonacci(count: u32) void {
    if (count == 0) return;

    var prev: u64 = 0;
    var curr: u64 = 1;
    var i: u32 = 0;

    while (i < count) : (i += 1) {
        print("F({d:>2}) = {d}\n", .{ i, prev });
        if (i + 1 < count) {
            const next = prev + curr;
            prev = curr;
            curr = next;
        }
    }
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // stdout prompt (flush before reading stdin)
    var out_buf: [256]u8 = undefined;
    var writer = std.Io.File.Writer.init(std.Io.File.stdout(), io, &out_buf);
    defer writer.flush() catch {};

    try writer.interface.print("Enter n (1–{d}): ", .{MAX_N});
    try writer.flush();

    // stdin reader
    // takeDelimiterExclusive returns a slice into in_buf up to (not including)
    // the '\n'. Use it before the next read. Delimiter stays buffered.
    var in_buf: [4096]u8 = undefined;
    var file_reader = std.Io.File.stdin().reader(io, &in_buf);
    const r = &file_reader.interface;

    const raw_line = r.takeDelimiterExclusive('\n') catch |err| switch (err) {
        error.EndOfStream  => { print("No input received.\n", .{}); return; },
        error.StreamTooLong => { print("Input too long.\n", .{}); return; },
        error.ReadFailed   => { print("Failed to read stdin.\n", .{}); return; },
    };

    // Trim '\r' for Windows \r\n line endings
    const line = std.mem.trimEnd(u8, raw_line, "\r");

    // parse & validate
    const n = std.fmt.parseInt(u32, line, 10) catch {
        print("Invalid input '{s}'. Please enter a positive integer.\n", .{line});
        return;
    };

    if (n == 0) {
        print("n must be at least 1.\n", .{});
        return;
    }

    const capped_n = if (n > MAX_N) blk: {
        print("n={d} exceeds max safe value ({d}) for u64. Capping.\n", .{ n, MAX_N });
        break :blk MAX_N;
    } else n;

    // output
    print("\nFirst {d} Fibonacci number(s):\n", .{capped_n});
    printFibonacci(capped_n);
}

```