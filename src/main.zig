const std = @import("std");
const Args = @import("args.zig");

const Interface = struct {
    writer: *std.Io.Writer,
    vtable: Vtable,

    const Vtable = struct {
        hello: *const fn (i: *Interface) anyerror!void,
    };

    pub fn greet(i: *Interface) !void {
        try i.vtable.hello(i);
        _ = try i.writer.write("\nInterface Method Write\n");
    }

    pub fn flush(i: *Interface) !void {
        try i.writer.flush();
    }
};

const Impl = struct {
    interface: Interface,
    number2: u16 = 0,
    poopoo: ?[]const u8 = null,

    fn hello(i: *Interface) !void {
        const self: *Impl = @alignCast(@fieldParentPtr("interface", i));
        try i.writer.print("{s}", .{self.poopoo orelse "placeholder"});
        _ = try i.writer.write(" - Oh I love agriculture. ");
        try i.writer.print(
            "\n{*}\n{*}\n{*}\n{*}\n",
            .{
                self,
                &self.poopoo,
                &self.number2,
                &self.interface,
            },
        );
    }

    pub fn flush(self: *Impl) !void {
        return self.interface.flush();
    }

    pub fn init(writer: *std.Io.Writer) Impl {
        return .{
            .interface = .{
                .vtable = .{
                    .hello = Impl.hello,
                },
                .writer = writer,
            },
        };
    }
};

pub fn main() !void {
    var args = Args.init();
    try args.parse();
    const dir = std.fs.cwd();
    var writer: std.fs.File.Writer = undefined;
    if (args.safe) {
        const file = try dir.createFile("output.txt", .{});
        var buf: [1024]u8 = undefined;
        writer = file.writer(&buf);
    }
    var impl = Impl.init(&writer.interface);
    try impl.interface.greet();
    try impl.flush();
}
