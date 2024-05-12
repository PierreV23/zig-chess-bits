const std = @import("std");
const builtin = @import("builtin");
const lib = @import("lib.zig");

pub const Pos = packed struct(u6) {
    hori: u3, // last 3 bits
    vert: u3, // first 3 bits
};

pub const PieceType = enum(u3) {
    None = 0b0,
    Pawn = 0b001,
    Bishop = 0b010,
    Knight = 0b011,
    Rook = 0b100,
    Queen = 0b101,
    King = 0b110,
    DPawn = 0b111, // Pawn that moved two spots as first move (en passant)
};

pub const Color = enum(u1) {
    Black = 0b0,
    White = 0b1,
};

pub const CastlingState = packed struct(u4) {
    const Self = @This();

    b_l_rook: bool,
    b_r_rook: bool,
    w_l_rook: bool,
    w_r_rook: bool,

    pub fn default() Self {
        const cs: Self = @bitCast(@as(u4, 0b1111));
        return cs;
    }
};

pub const Piece = packed struct(u4) {
    const Self = @This();

    // pos: Pos, // last 6 bits
    color: Color, // middle 1 bit
    piece_type: PieceType, // first 3 bits

    pub fn default() Self {
        return Self{ .color = .Black, .piece_type = .None };
    }

    const empty = default;

    pub fn rook(color: Color) Self {
        return Self{ .color = color, .piece_type = .Rook };
    }
    pub fn bishop(color: Color) Self {
        return Self{ .color = color, .piece_type = .Bishop };
    }
    pub fn knight(color: Color) Self {
        return Self{ .color = color, .piece_type = .Knight };
    }
    pub fn pawn(color: Color) Self {
        return Self{ .color = color, .piece_type = .Pawn };
    }
    pub fn queen(color: Color) Self {
        return Self{ .color = color, .piece_type = .Queen };
    }
    pub fn king(color: Color) Self {
        return Self{ .color = color, .piece_type = .King };
    }
};

pub const Board = struct {
    const Self = @This();

    turn: Color, // last 1 bit
    castling_state: CastlingState, // second last 4 bits
    field: u64, // middle 64 bits
    pieces: [32]Piece, // first 128 bits

    pub fn from_bits(bits: u197) Self {
        const turn: u1 = @truncate(bits);
        const castling_state: u4 = @truncate(bits >> 1);
        const field: u64 = @truncate(bits >> (1 + 4));
        const pieces: u128 = @truncate(bits >> (1 + 4 + 64));
        return Self{ .turn = @enumFromInt(turn), .castling_state = @bitCast(castling_state), .field = field, .pieces = lib.bitCastToArray(Piece, pieces) };
    }

    pub fn to_bits(self: Self) u197 {
        var bits: u197 = 0;
        bits += lib.bitCastFromArray(u128, self.pieces);
        bits <<= 64;
        bits += self.field;
        bits <<= 4;
        const cs: u4 = @bitCast(self.castling_state);
        bits += cs;
        bits <<= 1;
        const t: u1 = @intFromEnum(self.turn);
        bits += t;
        return bits;
    }
    pub fn default() Self {
        var array: [32]Piece = [_]Piece{Piece.default()} ** 32;
        inline for ([2]Color{ .Black, .White }) |color| {
            const offset = if (color == .Black) 0 else 24;
            array[0 + offset] = Piece.rook(color);
            array[1 + offset] = Piece.knight(color);
            array[2 + offset] = Piece.bishop(color);
            array[3 + offset] = Piece.queen(color);
            array[4 + offset] = Piece.king(color);
            array[5 + offset] = Piece.bishop(color);
            array[6 + offset] = Piece.knight(color);
            array[7 + offset] = Piece.rook(color);
        }

        inline for (8..16) |idx| {
            array[idx] = Piece.pawn(.Black);
        }
        inline for (16..24) |idx| {
            array[idx] = Piece.pawn(.White);
        }

        return Self{
            .turn = .White,
            .castling_state = CastlingState.default(),
            .field = 0b11111111_11111111_00000000_00000000_00000000_00000000_11111111_11111111,
            .pieces = array,
        };
    }
};
