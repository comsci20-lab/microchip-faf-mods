local UI = import('/lua/ui/uiutil.lua')
local L = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Popup = import('/lua/ui/controls/popups/popup.lua').Popup
local LagBot = import('/mods/Microchip-F11-Lag-Connectivity-Screen/modules/lagbot.lua')
local window

function Open(parent)
    if window and not IsDestroyed(window) then return window end
    parent = parent or GetFrame(0)
    local panel = Group(parent)
    panel.Width:Set(L.ScaleNumber(520)); panel.Height:Set(L.ScaleNumber(190))
    local bg = Bitmap(panel); bg:SetSolidColor('ff0c1520'); L.FillParent(bg, panel); bg:DisableHitTest()
    local popup = Popup(parent, panel)
    window = popup
    local oldClosed = popup.OnClosed
    popup.OnClosed = function(self) window = nil; oldClosed(self) end
    local function Text(value, size, x, y, color)
        local text = UI.CreateText(panel, value, size, UI.bodyFont)
        text:SetColor(color or 'ffffffff'); L.AtLeftTopIn(text, panel, x, y); text:DisableHitTest()
        return text
    end
    Text('Microchip F11 Lag Connectivity', 20, 22, 18)
    local checked = LagBot.Enabled()
    local box = Bitmap(panel); box:SetSolidColor('ff263b4b')
    box.Width:Set(L.ScaleNumber(23)); box.Height:Set(L.ScaleNumber(23))
    L.AtLeftTopIn(box, panel, 22, 62)
    local mark = UI.CreateText(box, checked and 'X' or '', 17, UI.bodyFont)
    mark:SetColor('ff59e0cf'); L.AtCenterIn(mark, box); mark:DisableHitTest()
    Text('Answer "who is lagging?" in chat with the top lagger', 15, 57, 63)
    Text('Replies "Bot: Top lagger is <name> ..." using total game wait.', 12, 57, 90, 'ff9fb1c2')
    Text('Also answers your own questions; at most once every 30 seconds.', 12, 57, 108, 'ff9fb1c2')
    box.HandleEvent = function(self, event)
        if event.Type == 'ButtonPress' then
            checked = not checked; mark:SetText(checked and 'X' or ''); LagBot.SetEnabled(checked); return true
        end
        return false
    end
    local close = UI.CreateButtonStd(panel, '/BUTTON/medium/', 'Close', 12)
    L.AtLeftTopIn(close, panel, 180, 135)
    close.OnClick = function() popup:Close() end
    return popup
end
