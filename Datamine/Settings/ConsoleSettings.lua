local L = Datamine.Strings;
local S = Datamine.Settings;
local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

local Console = {};

Console.Setting = {
    Console_Font = "Console_Font",
};

local parentCategory = S.GetTopLevelCategory();
local category = Settings.RegisterVerticalLayoutSubcategory(parentCategory, L.CONFIG_CATEGORY_CONSOLE);

do
    local default = "ConsoleFontNormal";
    local setting = S.RegisterSetting(category, Console.Setting.Console_Font, L.CONFIG_CONSOLE_FONT_NAME, default);

    local tooltip = L.CONFIG_CONSOLE_FONT_TOOLTIP;

    local function GetOptions()
        local container = Settings.CreateControlTextContainer();
        container:Add("ConsoleFontNormal", L.CONFIG_CONSOLE_FONT_DEFAULT_NAME, L.CONFIG_CONSOLE_FONT_DEFAULT_TOOLTIP);
        container:Add("DatamineConsoleFont", L.CONFIG_CONSOLE_FONT_CUSTOM_NAME, L.CONFIG_CONSOLE_FONT_CUSTOM_TOOLTIP);

        return container:GetData();
    end

    S.CreateDropdown(category, setting, GetOptions, tooltip);
end

------------

local function OnSettingChanged(_, variable, value)
    if variable == Console.Setting.Console_Font then
        local font = _G[value];
        if not font then
            Datamine.Utils.DebugError("Failed to set console font, font not found: " .. tostring(value));
            return;
        end

        local currentFont = DeveloperConsole.MessageFrame:GetFontObject()
        if currentFont:GetName() == font:GetName() then
            return;
        end

        local fontHeight = currentFont:GetFontHeight() or DeveloperConsole.savedVars.fontHeight;
        font:SetFontHeight(fontHeight);
        font:SetJustifyH("LEFT");

        DeveloperConsole.MessageFrame:SetFontObject(font);
        DeveloperConsole.EditBox:SetFontObject(font);
    end
end

Registry:RegisterCallback(Events.SETTING_CHANGED, OnSettingChanged);



