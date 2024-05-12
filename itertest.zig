const std = @import("std");

const strct = struct {
    const Self = @This();

    txt: []const u8,
    idx: usize,

    pub fn from(txt: []const u8) Self {
        return Self{
            .txt = txt,
            .idx = 0,
        };
    }

    pub fn next(self: *Self) ?u8 {
        if (self.idx == self.txt.len) return null;
        self.idx += 1;
        return self.txt[self.idx - 1];
    }
};

pub fn main() !void {
    var s = strct.from("hey");
    while (s.next()) |c| std.debug.print("{c}\n", .{c});
}
