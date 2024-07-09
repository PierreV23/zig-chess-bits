from collections import defaultdict
import threading
import time
from api import API
import requests

from chess import Color
from lib import decode_coord, fen_decoder

class ClaraChess(API):
    BASE_URL = ...
    def __init__(self, api_key: str, session_id):
        self.api_key = api_key
        self.session_id = session_id
        self.cache = {}
        self.cache_timer = 2
        self._name = None
        threading.Thread(target=self._fetch_name()).start()

    def _get_header(self):
        return {'session-id': self.session_id, 'x-api-key': self.api_key}

    def _fetch_name(self):
        res = requests.get(f"{self.BASE_URL}sessions", headers=self._get_header())
        assert res.status_code == 200, res.content
        sessions = res.json()["sessions"]
        names = [s[f"{s["color_to_move"].lower()}_player"] for s in sessions if s["your_turn"]]
        if not names:
            return
        assert all(n==names[0] for n in names), names
        self._name = names[0]
        

    @property
    def name(self):
        start = time.time()
        while self._name is None:
            if time.time() - start > 5:
                raise Exception()
            time.sleep(0.1)
        return self._name
    
    def get_gameboard(self):

        res = requests.get(f"{self.BASE_URL}session", headers={'session-id': self.session_id, 'x-api-key': self.api_key})
        assert res.status_code == 200
        data = res.json()
        print(data["fen"])
        return fen_decoder(data["fen"])

    def get_possible_moves(self):
        res = requests.get(f"{self.BASE_URL}session/move", headers={'session-id': self.session_id, 'x-api-key': self.api_key})
        assert res.status_code == 200
        data = res.json()
        moves = defaultdict(list)
        for fr, to in data['cells']:
            c = Color(data['color'][0].lower())
            fr = decode_coord(fr)
            to = decode_coord(to)
            moves[fr].append(to)
        print(c, data['color'], data['current_turn'], data['cells'])
        return moves

    def do_move(self, fr: str, to: str):
        res = requests.post(f"{self.BASE_URL}session/move?from={fr}&to={to}", headers={'session-id': self.session_id, 'x-api-key': self.api_key})
        print(res.content)
        assert res.status_code == 200, res.content
        return fen_decoder(res.json()['fen'])