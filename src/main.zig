const std = @import("std");

const Interface = struct {
    writer: *std.Io.Writer,
    vtable: Vtable,

    const Vtable = struct {
        hello: *const fn (i: *Interface) anyerror!void,
    };

    pub fn greet(i: *Interface) !void {
        try i.vtable.hello(i);
        _ = try i.writer.write("Interface Method Write\n");
    }

    pub fn flush(i: *Interface) !void {
        try i.writer.flush();
    }
};

const Impl = struct {
    slice: []const u8 = "burger",
    interface: Interface,

    fn hello(i: *Interface) !void {
        const self: *Impl = @alignCast(@fieldParentPtr("interface", i));
        _ = try i.writer.write("Oh I love agriculture.\n");
        try i.writer.print(
            "{*}\n{*}\n{*}\n{*}\n",
            .{
                i,
                self,
                &self.interface,
                &self.slice,
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
    const file = try std.fs.cwd().createFile("output.txt", .{});

    var buf: [1024]u8 = undefined;
    var writer = file.writer(&buf);
    var impl = Impl.init(&writer.interface);

    try (impl.interface).greet();
    try impl.flush();
}
