const std = @import("std");
const base32 = @import("base32");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    try encodeString();
    try stdout.print("\n", .{});
    try decodeString();
}

fn encodeString() !void {
    const input = "Hello World";
    const size = comptime base32.std_encoding.encodeLen(input.len);
    var buf: [size]u8 = undefined;
    const output = base32.std_encoding.encode(&buf, input);
    try stdout.print("base32 encoding:\n input: {s}\noutput: {s}\n", .{ input, output });
}

fn decodeString() !void {
    const input = "IJ4WKICXN5ZGYZA=";
    const size = comptime base32.std_encoding.decodeLen(input.len);
    var buf: [size]u8 = undefined;
    const output = try base32.std_encoding.decode(&buf, input);
    try stdout.print("base32 decoding:\n input: {s}\noutput: {s}\n", .{ input, output });
}
