
local moduleName = "Links";

local Print = function(...)
    Datamine.Utils.Print(moduleName, ...);
end

local LINK_CODE = "garrmission:datamine";
local LINK_COLOR = CreateColorFromHexString(Datamine.Slash.ArgumentColor);
local LINK_LENGTHS = LINK_CODE:len();

local FORMATTED_LINK_FORMAT = "|H%s:%s|h%s|h";

Datamine.Links = {};
Datamine.Links.SEPARATOR = ">";
Datamine.Links.Functions = {};

function Datamine.Links.GenerateLinkWithCallback(funcPattern, displayText, func)
    Datamine.Links.Functions[funcPattern] = func;

    local formattedName = "[" .. displayText .. "]";
    return LINK_COLOR:WrapTextInColorCode(string.format(FORMATTED_LINK_FORMAT, LINK_CODE, funcPattern, formattedName));
end

local function ExecuteLinkFunc(funcPattern)
    local func = Datamine.Links.Functions[funcPattern];
    if func then
        local success, result = pcall(func, funcPattern);
        if not success then
            Print(result);
        end
        ChatFrame_ScrollToBottom()
    end
end

hooksecurefunc("SetItemRef", function(link)
    local linkType = link:sub(1, LINK_LENGTHS);
    if linkType == LINK_CODE then
        local funcPattern = link:sub(LINK_LENGTHS + 2);
        ExecuteLinkFunc(funcPattern);
    end
end);
