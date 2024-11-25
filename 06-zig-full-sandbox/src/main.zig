const std = @import("std");
const log = std.log;
const HELLO_WORLD = @import("utils/hello_world.zig").hello_world;

pub fn main() !void {
    log.info("{s}", .{HELLO_WORLD});
}
