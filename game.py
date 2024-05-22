import asyncio
from collections import defaultdict
from enum import Enum
import json
import threading
import time
from typing import Optional
import pygame
from sys import argv
import pygame.display
import pygame.mouse
import pygame.transform
import requests
from win32api import GetSystemMetrics
pygame.init()
pygame.display.init()

from chess import *
from lib import *
from cs import *



pieces = {
    (color, piece_type): pygame.image.load(f"assets/{color.value}_{piece_type.value}.png")
    for color in Color
    for piece_type in PieceType
}

gameboard = {
    (0, 7): (Color.Black, PieceType.Rook),
    (1, 7): (Color.Black, PieceType.Knight),
    (2, 7): (Color.Black, PieceType.Bishop),
    (3, 7): (Color.Black, PieceType.Queen),
    (4, 7): (Color.Black, PieceType.King),
    (5, 7): (Color.Black, PieceType.Bishop),
    (6, 7): (Color.Black, PieceType.Knight),
    (7, 7): (Color.Black, PieceType.Rook),
    (0, 6): (Color.Black, PieceType.Pawn),
    (1, 6): (Color.Black, PieceType.Pawn),
    (2, 6): (Color.Black, PieceType.Pawn),
    (3, 0): (Color.Black, PieceType.Pawn),
    (4, 6): (Color.Black, PieceType.Pawn),
    (5, 6): (Color.Black, PieceType.Pawn),
    (6, 6): (Color.Black, PieceType.Pawn),
    (7, 6): (Color.Black, PieceType.Pawn),
}

# possible_moves: dict[tuple[int, int], list[tuple[int, int]]] = {
#     (1, 7): [(0, 5), (2, 5)],
#     (3, 7): [(3, 6), (3, 5), (3, 4), (3, 3), (3, 2), (3, 1)]
# }

board=pygame.image.load("assets/board.png")
width = height = 720
surface=pygame.display.set_mode((int(width), int(height)), pygame.RESIZABLE)

POV = Color.White
# POV = Color.Black



MOVING: Optional[tuple[int, int]] = None





alt = "9416301c9011494eae27a2bffe1ece75"
main = "05f342509dc2457b916867e2849610ca"
server = ClaraChess(alt, "664a7762041fb7eac75ade10")
# exit()
# server = ClaraChess(input("api key:"), "664a7762041fb7eac75ade10")

gameboard = server.get_gameboard()
possible_moves = server.get_possible_moves()
print(possible_moves)
task_dm = []
task_pm = []

while True:
    if task_dm:
        gameboard = task_dm[-1]
        task_dm.clear()
    if task_pm:
        possible_moves = task_pm[-1]
        task_dm.clear()
    was_moving = False
    if MOVING and not pygame.mouse.get_pressed(num_buttons=3)[0]:
        # print("NOT PRESSING")
        new = pov_translate(POV, *px_coord_to_grid_coord(scale, *pygame.mouse.get_pos()))
        new = new if new in possible_moves[MOVING] else None
        print(f"Moving from {MOVING} to {new}")
        if new:
            assert MOVING in possible_moves
            assert new in possible_moves[MOVING]
            fr = encode_coord(*MOVING)
            to = encode_coord(*new)
            gameboard[new] = gameboard.pop(MOVING)
            threading.Thread(target=lambda: task_dm.append(server.do_move(fr, to))).start()
            print("TTT")
            server.api_key = alt if server.api_key == main else main
            # gameboard = server.get_gameboard()
            time.sleep(1/60)
            threading.Thread(target=lambda: task_pm.append(server.get_possible_moves())).start()
        MOVING = None


    for event in pygame.event.get():
        if event.type==pygame.QUIT:
            pygame.quit()
            exit()
        if event.type==pygame.VIDEORESIZE:
            w, h = event.w, event.h
            dw, dh = w - width, h - height
            d = sum((dw, dh))
            width = height = w = h = max(144, max(w, h) if d > 0 else min(w, h))
            # print(w)
            surface = pygame.display.set_mode((w, h), pygame.RESIZABLE)
        if event.type==pygame.KEYDOWN:
            if event.key == pygame.K_r:
                print("REFRESHING")
                gameboard = {}
                possible_moves = []
                gameboard = server.get_gameboard()
                possible_moves = server.get_possible_moves()
    
    
    img=pygame.transform.scale(board, (int(width), int(height)))
    imgrect=img.get_rect()
    surface.blit(img, imgrect)
    scale=height/144
        
    mx, my = mouse_pos = pygame.mouse.get_pos()
    if MOVING or scale*16 <= mx <= scale*16 + scale*14*8 and scale*16 <= my <= scale*16 + scale*14*8:
        col, row = pov_translate(POV, *MOVING) if MOVING else px_coord_to_grid_coord(scale, mx, my)
        lbx, lby = grid_coord_to_px_coord(scale, col, row)
        # print(col, row)
        tcol, trow = pov_translate(POV, col, row)
        if moves:=possible_moves.get((tcol, trow)):
            if pygame.mouse.get_pressed(num_buttons=3)[0]:
                # print("Pressing", MOVING)
                MOVING = tcol, trow
            pygame.draw.rect(surface, (0, 255, 0), (lbx, lby, scale*14, scale*14), 3)
            for nx, ny in moves:
                lbx, lby = grid_coord_to_px_coord(scale, *pov_translate(POV, nx, ny))
                pygame.draw.rect(surface, (255, 255, 0), (lbx, lby, scale*14, scale*14), 3)
        else:
            if pygame.mouse.get_pressed(num_buttons=3)[0]:
                pygame.draw.rect(surface, (255, 0, 0), (lbx, lby, scale*14, scale*14), 3)  # width = 3
            else:
                pygame.draw.rect(surface, (0, 100, 255), (lbx, lby, scale*14, scale*14), 3)  # width = 3
    else:
        pygame.draw.circle(surface, (200, 0, 0), mouse_pos, scale*3)

    holding_color = None
    for (x, y), (c, pt) in gameboard.items():
        tx, ty = pov_translate(POV, x, y)
        piece = pieces[c, pt]
        piece=pygame.transform.scale(piece, (int(scale*14), int(scale*14)))
        if MOVING == (x, y):
            holding_color = c
            continue
            # print(1)
        else:
            surface.blit(piece, grid_coord_to_px_coord(scale, tx, ty))
    
    if MOVING:
        mx, my = pygame.mouse.get_pos()
        if MOVING not in gameboard:
            print("MOVING not in gameboard!!")
        else:
            piece=pieces[gameboard[MOVING]]
            piece=pygame.transform.scale(piece, (int(scale*14), int(scale*14)))
            surface.blit(piece, (mx - scale*7, my - scale*7))

    pygame.display.update()


