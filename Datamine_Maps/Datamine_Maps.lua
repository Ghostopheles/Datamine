local addonName, maps = ...;

Datamine.Maps = {};

function Datamine.Maps.GetMapInfo(mapName)
    for map in pairs(maps) do
        if map.MapName == mapName then
            return map
        end
    end
end