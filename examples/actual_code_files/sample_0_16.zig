/// sample_0_16.zig — exercises every major 0.16.0 pattern from zig-lockstep.
///
/// Run (no args):      zig run sample_0_16.zig
/// Run (with name):    zig run sample_0_16.zig -- Soumyajit
/// Run tests:          zig test sample_0_16.zig

const std = @import("std");
const print = std.debug.print;

// ---------------------------------------------------------------------------
// Domain type — uses exhaustive switch (non-negotiable compiler rule)
// ---------------------------------------------------------------------------

const Mood = enum { happy, grumpy, neutral };

fn describesMood(m: Mood) []const u8 {
    return switch (m) {
        .happy   => "😊 feeling great",
        .grumpy  => "😤 leave me alone",
        .neutral => "😐 just existing",
    };
}

// ---------------------------------------------------------------------------
// Allocating helper — fixed: use allocPrint so alloc size == free size
// ---------------------------------------------------------------------------

fn buildGreeting(allocator: std.mem.Allocator, name: []const u8) ![]u8 {
    // allocPrint allocates exactly the formatted length — no size mismatch.
    // Caller owns the returned slice and frees it directly.
    return std.fmt.allocPrint(allocator, "Hello, {s}! Welcome to 0.16.0.", .{name});
}

// ---------------------------------------------------------------------------
// State-machine demo — 0.16.0 `switch continue :label` dispatch
// ---------------------------------------------------------------------------

fn countdownFrom(start: u32) void {
    var state: u32 = start;
    dispatch: switch (state) {
        0 => print("  🚀 liftoff!\n", .{}),
        else => {
            print("  T-{d}\n", .{state});
            state -= 1;
            continue :dispatch state;
        },
    }
}

// ---------------------------------------------------------------------------
// main — args via init.args.iterate() (the pattern that burned us before)
// ---------------------------------------------------------------------------

pub fn main(init: std.process.Init.Minimal) void {
    // DebugAllocator (.init) is the 0.16.0 name for GeneralPurposeAllocator.
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer {
        const check = gpa.deinit();
        if (check == .leak) @panic("memory leak detected");
    }
    const allocator = gpa.allocator();

    // init.args is std.process.Args — call .iterate() first, then .next().
    var it = init.args.iterate();
    const prog = it.next() orelse "sample";   // argv[0]: program name
    const name = it.next() orelse "stranger"; // argv[1]: optional user arg

    print("\n=== zig-lockstep sample — 0.16.0 ===\n\n", .{});
    print("program : {s}\n", .{prog});
    print("name    : {s}\n\n", .{name});

    const greeting = buildGreeting(allocator, name) catch |err| {
        print("buildGreeting failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer allocator.free(greeting);
    print("{s}\n\n", .{greeting});

    // Exhaustive switch on enum
    const moods = [_]Mood{ .happy, .grumpy, .neutral };
    print("Mood report:\n", .{});
    for (moods) |mood| {
        print("  {s}\n", .{describesMood(mood)});
    }

    // switch continue :label dispatch
    print("\nCountdown:\n", .{});
    countdownFrom(3);

    // Integer arithmetic guards
    const a: u8 = 200;
    const b: u8 = 55;
    print("\nu8(200) +%  55 = {d}  (wrapping)\n",   .{a +% b});
    print("u8(200) +|  55 = {d}  (saturating)\n\n", .{a +| b});

    // Explicit cast — no implicit coercion allowed
    const small: u8  = 42;
    const large: u64 = @intCast(small);
    print("@intCast u8({d}) → u64({d})\n\n", .{ small, large });

    print("All checks passed ✓\n\n", .{});
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "describesMood covers all variants" {
    try std.testing.expectEqualStrings("😊 feeling great",  describesMood(.happy));
    try std.testing.expectEqualStrings("😤 leave me alone", describesMood(.grumpy));
    try std.testing.expectEqualStrings("😐 just existing",  describesMood(.neutral));
}

test "buildGreeting allocates and formats correctly" {
    const allocator = std.testing.allocator;
    const result = try buildGreeting(allocator, "Soumyajit");
    defer allocator.free(result);
    try std.testing.expectEqualStrings(
        "Hello, Soumyajit! Welcome to 0.16.0.",
        result,
    );
}

test "buildGreeting with empty name" {
    const allocator = std.testing.allocator;
    const result = try buildGreeting(allocator, "");
    defer allocator.free(result);
    try std.testing.expectEqualStrings(
        "Hello, ! Welcome to 0.16.0.",
        result,
    );
}

test "wrapping and saturating arithmetic" {
    const x: u8 = 200;
    try std.testing.expectEqual(@as(u8, 255), x +| 100);
    try std.testing.expectEqual(@as(u8, 44),  x +% 100);
}

test "intCast preserves value" {
    const small: u8  = 99;
    const large: u64 = @intCast(small);
    try std.testing.expectEqual(@as(u64, 99), large);
}
