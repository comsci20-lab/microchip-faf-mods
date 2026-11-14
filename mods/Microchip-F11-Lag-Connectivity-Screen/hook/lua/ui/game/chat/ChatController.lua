local LagBot = import('/mods/Microchip-F11-Lag-Connectivity-Screen/modules/lagbot.lua')
local lagBotAppend = AppendEntry

-- Received chat and the local player's own echoed messages both arrive here.
function AppendEntry(entry)
    lagBotAppend(entry)
    if entry and not entry.Camera and not entry.Location and (not entry.Type or entry.Type == 'Chat')
        and IsValidEntry(entry) then
        LagBot.Receive(entry.Text, entry.Recipient)
    end
end
