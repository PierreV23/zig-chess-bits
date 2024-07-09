from chess import *

def pov_translate(color: Color, x, y):
    if color == Color.White:
        return x, y
    else:
        return 7-x, 7-y

def px_coord_to_grid_coord(scale, x, y):
    col = int((x / scale - 16) // 14)
    row = int((y / scale - 16) // 14)
    return col, 7-row

def grid_coord_to_px_coord(scale, col, row):
    x = scale*16 + col*14*scale
    y = scale*16 + (7-row)*14*scale
    return x, y

def fen_decoder(fen):
    decoded = []
    for row in fen.split('/'):
        brow = []
        for c in row:
            if c == ' ':
                break
            elif c in '12345678':
                brow.extend( ['--'] * int(c) )
            elif c == 'p':
                brow.append( 'bp' )
            elif c == 'P':
                brow.append( 'wp' )
            elif c > 'Z':
                brow.append( 'b'+c.upper() )
            else:
                brow.append( 'w'+c )

        decoded.append( brow )
    gameboard = {}
    for y, row in enumerate(decoded):
        for x, (c, p) in enumerate(row):
            match p:
                case '-': continue
                case 'R': P = PieceType.Rook
                case 'N': P = PieceType.Knight
                case 'B': P = PieceType.Bishop
                case 'Q': P = PieceType.Queen
                case 'K': P = PieceType.King
                case 'p': P = PieceType.Pawn
            gameboard[(x, 7-y)] = (Color(c), P)
    return gameboard



def decode_coord(pos: str):
    l, i = pos
    return ord(l) - 65, int(i) - 1

def encode_coord(x, y):
    c = f"{chr(x+65)}{str(y+1)}"
    print(c)
    return c