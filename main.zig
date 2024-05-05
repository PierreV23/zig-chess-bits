const std = @import("std");

const Pos = packed struct(u6) {
    hori: u3, // last 3 bits
    vert: u3, // first 3 bits
};

const PieceType = enum(u3) {
    Pawn = 0b0000,
    Bishop = 0b0001,
    Knight = 0b0010,
    Rook = 0b0011,
    Queen = 0b0100,
    King = 0b0101,
    DPawn = 0b0111, // Pawn that moved two spots as first move (en passant)
    // DPawn = 0b1000, // Pawn that moved two spots as first move (en passant)
    // URook = 0b1011, // Rook that hasnt moved yet (castling)
    // UKing = 0b1101, // King that hasnt moved yet (castling)
    // Maybe seperate the latter 3 behaviour to a seperate field
};

const Color = enum(u1) {
    Black = 0b0,
    White = 0b1,
};

const CastlingState = packed struct(u4) {
    b_l_rook: bool,
    b_r_rook: bool,
    w_l_rook: bool,
    w_r_rook: bool,
};

const Piece = packed struct(u10) {
    pos: Pos, // last 6 bits
    color: Color, // middle 1 bit
    piece_type: PieceType, // first 3 bits
};

// castling_state: CastlingState, // first 4 bits

// const LastMove = packed struct {
//     piece_type: PieceType,
//     color: Color,
//     prev_pos: Pos,
//     new_pos: Pos,
// }

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    // const allocator = gpa.allocator();

    var piece: u3 = @intFromEnum(PieceType.King);
    var pos: u6 = @bitCast(Pos{ .hori = 1, .vert = 5 });

    try stdout.print("{b:04} {b:06}\n", .{ piece, pos });
    // Output of above: `101 101001`
    // 101 is Piece.King
    // first 3 bits 101 is equal to 5
    // last 3 bits 001 is equal to 1

    var new_pos_raw: u6 = pos | 0b101011;
    var new_pos: Pos = @bitCast(new_pos_raw);
    try stdout.print("{}\n", .{new_pos});

    var pi = Piece{ .pos = @bitCast(pos), .color = .Black, .piece_type = @enumFromInt(piece) };
    var pi_int: u10 = @bitCast(pi);
    try stdout.print("{b:011}\n", .{pi_int});

    var new_pi_int: u10 = pi_int | 0b111;
    var new_pi: Piece = @bitCast(new_pi_int);
    try stdout.print("{}\n", .{new_pi});

    // validate a move by using xor and then (n & (n-1)) == 0
}
