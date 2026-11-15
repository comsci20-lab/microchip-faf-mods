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
--- slowest (optional): {names = {...}, rate = n}, the players whose PCs report the lowest
--- max sim speed; added as "Slowest sim: name (-2)." when one is lower than the others.
function ReplyText(ranked, format, slowest)
    local top = ranked and ranked[1]
    local recent
    for _, row in ipairs(ranked or {}) do
        if row.recentWaitSeconds and row.recentWaitSeconds > 0
            and (not recent or row.recentWaitSeconds > recent.recentWaitSeconds) then
            recent = row
        end
    end
    local hasTotal = top and top.totalWaitSeconds and top.totalWaitSeconds > 0
    local simText = ''
    if slowest and slowest.names and table.getn(slowest.names) > 0 then
        local rate = slowest.rate >= 0 and ('+' .. string.format('%d', slowest.rate)) or string.format('%d', slowest.rate)
        local shown = {}
        for i = 1, math.min(3, table.getn(slowest.names)) do shown[i] = slowest.names[i] end
        local more = table.getn(slowest.names) - table.getn(shown)
        simText = string.format(' Slowest sim: %s%s (%s).', table.concat(shown, ', '),
            more > 0 and (' +' .. more) or '', rate)
    end
    if not hasTotal and not recent then
        return 'Bot: No lag measured yet.' .. simText
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
    return text .. simText
end

--- The connected players (you included) whose PCs report the lowest max sim speed, or nil
--- when nobody is slower than the others.
function SlowestPlayers(clients, analysis)
    local rate = analysis.SlowestSpeed(clients)
    if not rate then return nil end
    local names = {}
    for _, client in pairs(clients or {}) do
        if client.connected ~= false and analysis.MaxSpeed(client) == rate then
            table.insert(names, tostring(client.name or 'Player'))
        end
    end
    table.sort(names)
    return {names = names, rate = rate}
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
        local clients = GetSessionClients() or {}
        local reply = ReplyText(LagLinks.Ranked(clients), LagLinks.FormatWaitDuration, SlowestPlayers(clients, LagLinks))
        local chat = import('/lua/ui/game/chat/ChatController.lua')
        local army = GetArmiesTable()
        local me = army.focusArmy > 0 and army.armiesTable[army.focusArmy].nickname or nil
        SessionSendChatMessage(chat.FindClients(), {from = me, to = to == 'allies' and 'allies' or 'all', Chat = true, text = reply})
    end)
    if not ok then WARN('Microchip lag bot: ' .. tostring(problem)) end
end
