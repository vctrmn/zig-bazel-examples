const printHelloWorld = @import("utils/hello.zig").printHelloWorld;
const base32 = @import("base32");

pub fn main() !void {
    try printHelloWorld();
}
