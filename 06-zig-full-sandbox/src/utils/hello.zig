const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn printHelloWorld() !void {
    try stdout.print("Hello World !\n", .{});
}
