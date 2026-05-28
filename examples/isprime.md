```zig
/// isprime.zig — Read a number from stdin, print "true" if prime, "false" otherwise.
///
/// Compile:  zig build-exe isprime.zig
/// Run:      ./isprime

const std = @import("std");
const print = std.debug.print;

/// Returns true if n is a prime number.
/// 0 and 1 are not prime by definition.
fn isPrime(n: u64) bool {
    if (n < 2) return false;
    if (n == 2) return true;
    // Even numbers greater than 2 are not prime.
    if (n % 2 == 0) return false;

    var divisor: u64 = 3;
    // Only check odd divisors up to sqrt(n).
    while (divisor * divisor <= n) : (divisor += 2) {
        if (n % divisor == 0) return false;
    }
    return true;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    var out_buf: [64]u8 = undefined;
    var writer = std.Io.File.Writer.init(std.Io.File.stdout(), io, &out_buf);
    // Flush errors on exit are not recoverable; ignore intentionally.
    defer writer.flush() catch {};

    try writer.interface.print("Enter a number: ", .{});
    // Flush before blocking on stdin so the prompt appears first.
    try writer.flush();

    var in_buf: [64]u8 = undefined;
    var file_reader = std.Io.File.stdin().reader(io, &in_buf);
    const r = &file_reader.interface;

    const raw_line = r.takeDelimiterExclusive('\n') catch |err| switch (err) {
        error.EndOfStream   => { print("No input received.\n",  .{}); return; },
        error.StreamTooLong => { print("Input too long.\n",     .{}); return; },
        error.ReadFailed    => { print("stdin read failed.\n",  .{}); return; },
    };

    // Strip trailing \r for Windows compatibility.
    const line = std.mem.trimEnd(u8, raw_line, "\r");

    const num = std.fmt.parseInt(u64, line, 10) catch {
        print("'{s}' is not a valid non-negative integer.\n", .{line});
        return;
    };

    print("{}\n", .{isPrime(num)});
}
```