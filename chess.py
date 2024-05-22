from enum import Enum


class Color(Enum):
    Black = 'b'
    White = 'w'


class PieceType(Enum):
    Pawn = 'pawn'
    Rook = 'rook'
    Knight = 'knight'
    Bishop = 'bishop'
    Queen = 'queen'
    King = 'king'