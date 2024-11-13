const std = @import("std");
const log = std.log;
const zap = @import("zap");

pub fn main() void {
    log.info("{s} !", .{zap.hello_world});
}
