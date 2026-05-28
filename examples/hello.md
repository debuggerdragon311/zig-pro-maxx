```zig
/// hello.zig — Prompts for a first name and prints a greeting.
///
/// Run: zig run hello.zig

const std = @import("std");
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // Stack buffer for stdin — 4 KB is plenty for a name.
    var in_buf: [4096]u8 = undefined;
    var file_reader = std.Io.File.stdin().reader(io, &in_buf);
    const r = &file_reader.interface;

    // Prompt
    print("Enter your name (first name): ", .{});

    // Read one line, excluding the newline delimiter.
    const raw = try r.takeDelimiterExclusive('\n');

    // Trim trailing carriage return for Windows \r\n compatibility.
    const name = std.mem.trimEnd(u8, raw, "\r");

    // Greet
    print("Hello!! {s}\n", .{name});
}
```