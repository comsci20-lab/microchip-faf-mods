"""Ready Alert tests: Python + lupa, no game required."""
from pathlib import Path
import unittest
from lupa.lua51 import LuaRuntime

MOD = Path(__file__).resolve().parents[2] / 'mods/Microchip-Lobby-Ready-Alert/readyalert.lua'


class ReadyAlertTests(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(MOD.read_text(encoding='utf-8'))
        self.events = []
        g = self.lua.globals()
        g.ConExecute = lambda cmd: self.events.append(cmd)
        g.PlaySound = lambda s: self.events.append('sound')
        g.Sound = lambda t: t
        self.now = 0.0
        g.GetSystemTimeSeconds = lambda: self.now

    def lobby(self, *players):
        # players: (OwnerID, Human, Ready); PlayerOptions exposes :pairs() like FAF's watched array.
        rows = self.lua.table_from({i + 1: self.lua.table_from({'OwnerID': o, 'Human': h, 'Ready': r})
                                    for i, (o, h, r) in enumerate(players)})
        return self.lua.eval('function(rows) return {pairs = function(self) return pairs(rows) end} end')(rows)

    def test_others_ready_ignores_me(self):
        ready = self.lua.globals().OthersReady
        self.assertTrue(ready(self.lobby(('me', True, False), ('a', True, True)), 'me'))
        self.assertFalse(ready(self.lobby(('me', True, True), ('a', True, False)), 'me'))

    def test_needs_another_human(self):
        ready = self.lua.globals().OthersReady
        self.assertFalse(ready(self.lobby(('me', True, True)), 'me'))
        self.assertFalse(ready(self.lobby(('me', True, False), ('ai', False, False)), 'me'))

    def test_watch_alerts_once_after_hold_and_rearms(self):
        states = [self.lobby(('me', True, False), ('a', True, True))] * 8 + \
                 [self.lobby(('me', True, False), ('a', True, False))] + \
                 [self.lobby(('me', True, False), ('a', True, True))] * 6 + [None]
        it = iter(states)
        current = {'v': next(it)}
        def get_players():
            return current['v']
        def wait(seconds):
            self.now += seconds
            current['v'] = next(it)
        g = self.lua.globals()
        g.WaitSeconds = wait
        g.WatchLobby(get_players, lambda: 'me')
        # Ready from t=0, alert at t>=1; unready re-arms; ready again, alert after another second.
        self.assertEqual(self.events, ['SC_FlashGameWindow', 'sound', 'SC_FlashGameWindow', 'sound'])

    def test_quick_ready_unready_does_not_alert(self):
        states = [self.lobby(('me', True, False), ('a', True, True)),
                  self.lobby(('me', True, False), ('a', True, False))] * 4 + [None]
        it = iter(states)
        current = {'v': next(it)}
        g = self.lua.globals()
        g.WaitSeconds = lambda s: (setattr(self, 'now', self.now + s), current.__setitem__('v', next(it)))
        g.WatchLobby(lambda: current['v'], lambda: 'me')
        self.assertEqual(self.events, [])


if __name__ == '__main__':
    unittest.main()
