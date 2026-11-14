function Main()
    UMT.Options.AddOptions('Microchip-F11-Lag-Connectivity-Screen', 'Microchip F11 Lag Connectivity', function(parent)
        return import('/mods/Microchip-F11-Lag-Connectivity-Screen/modules/options.lua').Open(parent)
    end)
end
