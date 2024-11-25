const printHelloWorld = @import("utils/hello.zig").printHelloWorld;

pub fn main() !void {
    try printHelloWorld();
}
