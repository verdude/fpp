const std = @import("std");
const mem = std.mem;

fn is_option(arg: []const u8, long: []const u8, short: []const u8) bool {
    if (arg.len == long.len) return mem.eql(u8, arg, long);
    if (arg.len == short.len) return mem.eql(u8, arg, short);
    return false;
}

pub const CliArgs = struct {
    safe: bool = false,

    pub fn parse(self: *CliArgs) !void {
        var argi = std.process.ArgIteratorPosix.init();
        _ = argi.next();
        while (true) {
            const arg = argi.next() orelse break;
            if (is_option(arg, "--safe", "-s")) {
                self.safe = true;
            } else {
                return error.UnknownCliArgument;
            }
        }
    }
};

pub fn init() CliArgs {
    return .{};
}
