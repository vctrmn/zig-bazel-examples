const std = @import("std");
const base32 = @import("base32");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    try encodeString();
}

fn encodeString() !void {
    const input = "Hello World";
    const size = comptime base32.std_encoding.encodeLen(input.len);
    var buf: [size]u8 = undefined;
    const output = base32.std_encoding.encode(&buf, input);
    try stdout.print("base32 encoding:\n input: {s}\noutput: {s}\n", .{ input, output });
}
