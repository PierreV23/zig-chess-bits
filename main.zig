const std = @import("std");
const builtin = @import("builtin");
const lib = @import("lib.zig");
const chess = @import("chess.zig");
const ansi = @import("ansi.zig");

pub fn main() !void {
    if (builtin.os.tag == .windows) {
        const wkernel32 = std.os.windows.kernel32;
        if (wkernel32.SetConsoleOutputCP(65001) == 0) {
            std.debug.panic("Panicked when trying to set terminal to utf8: {s}", .{@tagName(wkernel32.GetLastError())});
        }
    }
    const stdout = std.io.getStdOut().writer();

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    // const allocator = gpa.allocator();

    var gameboard = chess.Board.default();
    gameboard.field = 0b11111111_11111111_00000000_00000000_00000000_10000000_01111111_11111111;
    try stdout.print("{b}\n", .{gameboard.to_bits()});
    try print_board(stdout, gameboard, .Black);
}

pub fn print_board(writer: std.fs.File.Writer, board: chess.Board, perspective: chess.Color) !void {
    const VERTI_CHARS = "12345678";
    const field: u64 = if (perspective == .White) board.field else lib.reverse_u64(board.field);
    var bitcount: usize = 0;
    const col_coords = if (perspective == .White) "A B C D E F G H" else "H G F E D C B A";
    try writer.print("{s} {s}  {s}\n", .{ ansi.GRAY, col_coords, ansi.RESET });
    for (0..64) |idx| {
        const row = idx % 8;
        const col = idx / 8;
        const shift: u6 = @intCast(idx);
        const bit = (field >> shift) & 1;
        const piece_idx = if (perspective == .White) bitcount else 31 - bitcount;
        const piece = board.pieces[piece_idx];
        const char = if (bit != 1) " " else switch (piece.piece_type) {
            .Pawn, .DPawn => "♙",
            .Knight => "♞",
            .Bishop => "♝",
            .Rook => "♜",
            .Queen => "♛",
            .King => "♚",
            .None => unreachable,
        };
        const color = if (piece.color == .Black) "\x1b[30m" else "\x1b[97m";
        const row_coord = VERTI_CHARS[if (perspective == .White) 7 - col else col];
        if (row == 0) try writer.print("{s}{c}", .{ ansi.GRAY, row_coord });
        const background = if ((row + col) % 2 == 0) ansi.WOOD else ansi.LIGHT_WOOD;
        try writer.print("{s}{s}{s} {s}", .{ background, color, char, ansi.RESET });
        if (row == 7) try writer.print("{s}{c}{s}\n", .{ ansi.GRAY, row_coord, ansi.RESET });
        if (bit == 1) bitcount += 1;
    }
    try writer.print("{s} {s}  {s}\n", .{ ansi.GRAY, col_coords, ansi.RESET });
    // try std.fmt.format(writer, "\n{s}\n", .{RESET});
}
