-- Answers "who is lagging?" chat questions with the player who has the most total game wait.
local PREF = 'microchip_f11_lag_bot'
-- Short enough that a second player asking a few seconds later still gets an answer
-- (replay 28118078: questions 6 s apart, the second was ignored); long enough to stop chat loops.
local COOLDOWN = 5
local lastReply

local function Words(text)
    return ' ' .. string.gsub(string.lower(text), "[^%w%?']", ' ') .. ' '
end

--- Questions seen in replay chat: "lag?", "who lag?", "whos lagging", "someone lagging", "laggy???", "am i lagging ?".
function IsLagQuestion(text)
    if type(text) ~= 'string' or string.find(string.lower(text), '^%s*bot[%s:]') then return false end
    local words = Words(text)
    if not string.find(words, '[^%w]lag') then return false end
    if string.find(words, '%?') then return true end
    for _, ask in ipairs({' who ', ' whos ', ' whose ', " who's ", ' someone ', " someone's ", ' anyone '}) do
        if string.find(words, ask, 1, true) then return true end
    end
    return false
end

--- Reply text for ranked F11 rows (analysis.lua Ranked), or nil when nobody has measured wait.
--- Names the player with the most total game wait (ranked[1]) and, separately, the one with the
--- most wait in the last 30 seconds.
function ReplyText(ranked, format)
    local top = ranked and ranked[1]
    local recent
    for _, row in ipairs(ranked or {}) do
        if row.recentWaitSeconds and row.recentWaitSeconds > 0
            and (not recent or row.recentWaitSeconds > recent.recentWaitSeconds) then
            recent = row
        end
    end
    local hasTotal = top and top.totalWaitSeconds and top.totalWaitSeconds > 0
    if not hasTotal and not recent then
        return 'Bot: No lag measured yet.'
    end
    local text = 'Bot:'
    if hasTotal then
        text = text .. string.format(' Most game lag: %s (%s total).',
            tostring(top.client.name or 'Player'), format(top.totalWaitSeconds))
    end
    if recent then
        text = text .. string.format(' Last 30s: %s (%s).',
            tostring(recent.client.name or 'Player'), format(recent.recentWaitSeconds))
    else
        text = text .. ' Last 30s: nobody.'
    end
    return text
end

function Enabled()
    local Prefs = import('/lua/user/prefs.lua')
    return Prefs.GetFromCurrentProfile(PREF) == true
end

function SetEnabled(value)
    import('/lua/user/prefs.lua').SetToCurrentProfile(PREF, value and true or false)
end

function Receive(text, to)
    if not Enabled() or not IsLagQuestion(text) or SessionIsReplay() then return end
    local now = GetSystemTimeSeconds()
    if lastReply and now - lastReply < COOLDOWN then return end
    lastReply = now
    local ok, problem = pcall(function()
        local LagLinks = import('/mods/Microchip-F11-Lag-Connectivity-Screen/modules/analysis.lua')
        local reply = ReplyText(LagLinks.Ranked(GetSessionClients() or {}), LagLinks.FormatWaitDuration)
        local chat = import('/lua/ui/game/chat/ChatController.lua')
        local army = GetArmiesTable()
        local me = army.focusArmy > 0 and army.armiesTable[army.focusArmy].nickname or nil
        SessionSendChatMessage(chat.FindClients(), {from = me, to = to == 'allies' and 'allies' or 'all', Chat = true, text = reply})
    end)
    if not ok then WARN('Microchip lag bot: ' .. tostring(problem)) end
end
