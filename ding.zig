const std = @import("std");
const lib = @import("lib.zig");

pub fn main() !void {
    // const n: u16 = 0b10110000_00001111;
    // const arr: [2]u8 = @bitCast(n);
    // std.debug.print("{b}  {b}\n", .{ arr[0], arr[1] });
    // above works

    const n2: u4 = 0b1011;
    var arr2: [2]u2 = undefined;
    const n = @typeInfo(@TypeOf(n2)).Int.bits / 8 + 1;
    const I = @Type(.{ .Int = .{ .bits = n * 8, .signedness = .unsigned } });
    // const I = u8;
    var bytes: [n]u8 = @bitCast(@as(I, n2));
    const s = std.PackedIntSlice(u2).init(&bytes, 2);
    arr2[0] = s.get(0);
    arr2[1] = s.get(1);
    // const arr2: [2]u2 = @bitCast(n2);
    std.debug.print("{b}  {b}\n", .{ arr2[0], arr2[1] });

    const n3: u6 = 0b101101;
    const arr3: [3]u2 = lib.bitCastArray(u2, n3);
    std.debug.print("{b} {b} {b}\n", .{ arr3[0], arr3[1], arr3[2] });

    const TwoBits = enum(u2) {
        Zero = 0b00,
        One = 0b01,
        Two = 0b10,
        Three = 0b11,
    };
    const num: u6 = 0b10_11_01;
    const arr: [3]TwoBits = lib.bitCastArray(TwoBits, num);
    std.debug.print("{} {} {}\n", .{ arr[0], arr[1], arr[2] });
    // TwoBits.One TwoBits.Three TwoBits.Two

    const field: u64 = 0b11111111_11111111_00000000_00000000_00000000_00000000_00000000_10000001;
    const board: [8]u8 = lib.bitCastArray(u8, field);
    std.debug.print("0:{b:08}\n1:{b:08}\n2:{b:08}\n3:{b:08}\n4:{b:08}\n5:{b:08}\n6:{b:08}\n7:{b:08}\n", .{
        board[0],
        board[1],
        board[2],
        board[3],
        board[4],
        board[5],
        board[6],
        board[7],
    });
}
