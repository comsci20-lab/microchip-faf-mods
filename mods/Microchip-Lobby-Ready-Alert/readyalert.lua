-- True when every seated human except you is Ready and there is at least one such player.
-- localID is your OwnerID; with no localID (older faf-re hook) every human must be Ready.
function OthersReady(players, localID)
    local others = 0
    for _, player in players:pairs() do
        if player.Human and (localID == nil or tostring(player.OwnerID) ~= tostring(localID)) then
            if not player.Ready then
                return false
            end
            others = others + 1
        end
    end
    return others > 0
end

-- getPlayers returns gameInfo.PlayerOptions (nil once the lobby closes); getLocalID your OwnerID.
-- Alerts once each time the others have stayed Ready for HOLD seconds, so a quick
-- ready/unready does not set it off.
local HOLD = 1
function WatchLobby(getPlayers, getLocalID)
    local alerted, readySince = false, nil
    local players = getPlayers()
    while players do
        -- FAF temporarily flattens PlayerOptions during launch.
        if players.pairs then
            local ready = OthersReady(players, getLocalID and getLocalID() or nil)
            local now = GetSystemTimeSeconds()
            if not ready then
                alerted, readySince = false, nil
            elseif not readySince then
                readySince = now
            elseif not alerted and now - readySince >= HOLD then
                alerted = true
                ConExecute('SC_FlashGameWindow')
                PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Comm_UEF_In'}))
            end
        end
        WaitSeconds(0.25)
        players = getPlayers()
    end
end
