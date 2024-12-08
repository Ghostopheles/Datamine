local L = Datamine.Strings;
local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

if C_CVar.GetCVar("debugTargetInfo") == nil then
    C_CVar.RegisterCVar("debugTargetInfo", 0);
end

Datamine.Settings = {};

Datamine.Setting = {
    ChatPrefixColor = "ChatPrefixColor",
    debugTargetInfo = "debugTargetInfo", -- this one is a cvar, hence the weird capitalization
    CollectCreatureData = "CollectCreatureData",
    AutoLoadMapData = "AutoLoadMapData",
    ShowModelInfo = "ShowModelInfo",
    -- will also include all settings registered externally
};

local defaultConfig = {
    [Datamine.Setting.ChatPrefixColor] = "FFF542F5",
    [Datamine.Setting.debugTargetInfo] = false,
    [Datamine.Setting.CollectCreatureData] = false,
    [Datamine.Setting.AutoLoadMapData] = false,
    [Datamine.Setting.ShowModelInfo] = true,
    -- will also include all settings registered externally
};

local mt = {
    __index = function(t, k)
        if DatamineConfig then
            return DatamineConfig[k];
        end
    end,
    __newindex = function(t, k, v)
        if DatamineConfig then
            DatamineConfig[k] = v;
        else
            rawset(t, k, v);
        end
    end
};
local middleman = {};
setmetatable(middleman, mt);

local function InitSavedVariables()
    if not DatamineConfig then
        DatamineConfig = CopyTable(defaultConfig);
    end

    for k, v in pairs(defaultConfig) do
        if DatamineConfig[k] == nil then
            DatamineConfig[k] = v;
        end
    end

    for k, v in pairs(DatamineConfig) do
        local variable = k;
        local setting = Settings.GetSetting(variable);
        if not setting then
            setting = Settings.GetSetting("DM_" .. variable);
        end

        if setting then
            local immediate = true;
            setting:SetValue(v, immediate);
        end
    end
    wipe(middleman);

    Datamine.Constants.ChatPrefixColor = CreateColorFromHexString(DatamineConfig.ChatPrefixColor);
end

EventUtil.ContinueOnAddOnLoaded("Datamine", InitSavedVariables);

local function OnSettingChanged(_, setting, value)
	local variable = setting:GetVariable();
    Registry:TriggerEvent(Events.SETTING_CHANGED, variable, value);
end

local function CreateCVarProxySetting(category, name, variable, defaultValue)
    local cvar = variable;
    variable = "DM_" .. variable;
    local variableType = type(defaultValue);
    local accessor = CreateCVarAccessor(cvar, variableType);

    local function GetValue()
        local value = accessor:GetValue();
        return accessor:ConvertValue(value);
    end

    local function SetValue(value)
        accessor:SetValue(value);
        DatamineConfig[cvar] = value; -- hack fix and I hate it
        return value;
    end

    local setting = Settings.RegisterProxySetting(category, variable, variableType, name, defaultValue, GetValue, SetValue);
    return setting;
end

local function CreateCVarSetting(category, name, variable, defaultValue)
    local setting = CreateCVarProxySetting(category, name, variable, defaultValue);

    return setting;
end

local function ShowColorPicker(setting)
    local startHexString = setting:GetValue();
    local r, g, b = CreateColorFromHexString(startHexString):GetRGB();

    local function OnColorChanged()
        local newR, newG, newB = ColorPickerFrame:GetColorRGB();
        local hexString = CreateColor(newR, newG, newB):GenerateHexColor();
        setting:SetValue(hexString);
    end

    local function OnCancel()
        setting:SetValue(startHexString);
    end

    local options = {
        swatchFunc = Datamine.Utils.Debounce(0.1, OnColorChanged),
        cancelFunc = OnCancel,
        r = r,
        g = g,
        b = b,
    };

    ColorPickerFrame:SetupColorPickerAndShow(options);
end

local function RegisterSetting(category, variable, name, defaultValue)
    Datamine.Setting[variable] = variable;
    defaultConfig[variable] = defaultValue;
    local variableType = type(defaultValue);
    local setting = Settings.RegisterAddOnSetting(category, variable, variable, middleman, variableType, name, defaultValue);

    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);

    return setting;
end

Datamine.Settings.RegisterSetting = RegisterSetting;

local function CreateColorPickerButtonForSetting(category, setting, name, tooltip, buttonText, noSearchTags)
    buttonText = buttonText or L.CONFIG_COLOR_PICKER_TEXT;

    local function OnButtonClick(button, buttonName, down)
        ShowColorPicker(setting);
    end

    local searchTags;
    if noSearchTags then
        searchTags = false;
    else
        searchTags = true;
    end

    local initializer = CreateSettingsButtonInitializer(name, buttonText, OnButtonClick, tooltip, searchTags);
    local layout = SettingsPanel:GetLayout(category);
    layout:AddInitializer(initializer);

    return initializer;
end

Datamine.Settings.CreateColorPickerButton = CreateColorPickerButtonForSetting;

local function CreateHeader(category, name)
    local initializer = Settings.CreateSettingsInitializer("SettingsListSectionHeaderTemplate", { name = name });
    local layout = SettingsPanel:GetLayout(category);
    layout:AddInitializer(initializer);

    return initializer;
end

Datamine.Settings.CreateHeader = CreateHeader;

local function CreateCheckbox(category, setting, tooltip)
    return Settings.CreateCheckbox(category, setting, tooltip);
end

Datamine.Settings.CreateCheckbox = CreateCheckbox;

local function CreateDropdown(category, setting, options, tooltip)
    local initializer = Settings.CreateDropdownInitializer(setting, options, tooltip);
    local layout = SettingsPanel:GetLayout(category);
    layout:AddInitializer(initializer);

    return initializer;
end

Datamine.Settings.CreateDropdown = CreateDropdown;

------------

local category = Settings.RegisterVerticalLayoutCategory(Datamine.Constants.AddonName);

do
    local variable = Datamine.Setting.ChatPrefixColor;
    local name = L.CONFIG_CHAT_PREFIX_COLOR_NAME;
    local tooltip = L.CONFIG_CHAT_PREFIX_COLOR_TOOLTIP;

    local setting = RegisterSetting(category, variable, name, defaultConfig[variable]);

    CreateColorPickerButtonForSetting(category, setting, name, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);
end

do
    local variable = Datamine.Setting.debugTargetInfo;
    local name = L.CONFIG_DEBUGTARGETINFO_NAME;
    local tooltip = L.CONFIG_DEBUGTARGETINFO_TOOLTIP;

    local setting = CreateCVarSetting(category, name, variable, defaultConfig[variable]);
    CreateCheckbox(category, setting, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);
end

do
    local variable = Datamine.Setting.CollectCreatureData;
    local name = L.CONFIG_CREATUREDATA_NAME;
    local tooltip = L.CONFIG_CREATUREDATA_TOOLTIP;

    local setting = RegisterSetting(category, variable, name, defaultConfig[variable]);
    CreateCheckbox(category, setting, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);
end

do
    local variable = Datamine.Setting.AutoLoadMapData;
    local name = L.CONFIG_AUTO_LOAD_MAP_DATA_NAME;
    local tooltip = L.CONFIG_AUTO_LOAD_MAP_DATA_TOOLTIP;

    local setting = RegisterSetting(category, variable, name, defaultConfig[variable]);
    CreateCheckbox(category, setting, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);
end

do
    local variable = Datamine.Setting.ShowModelInfo;
    local name = L.CONFIG_SHOW_MODEL_INFO_NAME;
    local tooltip = L.CONFIG_SHOW_MODEL_INFO_TOOLTIP;

    local setting = RegisterSetting(category, variable, name, defaultConfig[variable]);
    CreateCheckbox(category, setting, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);
end

Settings.RegisterAddOnCategory(category);

------------

function Datamine.Settings.GetSetting(name)
    return Settings.GetValue(name);
end

function Datamine.Settings.GetSettingObject(name)
    return Settings.GetSetting(name);
end

function Datamine.Settings.GetColor(name)
    local value = Settings.GetValue(name);
    if value then
        return CreateColorFromHexString(value);
    end
end

function Datamine.Settings.GetTopLevelCategory()
    return category;
end

function Datamine.Settings.OpenSettings(categoryID)
    Settings.OpenToCategory(categoryID);
end

------------

local DATAMINE_MAPS = "Datamine_Maps";

if C_AddOns.GetAddOnEnableState(DATAMINE_MAPS) ~= Enum.AddOnEnableState.All then
    C_AddOns.EnableAddOn(DATAMINE_MAPS);
end

-- handler for the AutoLoadMapData config option
EventUtil.ContinueOnAddOnLoaded("Datamine", function()
    if Datamine.Settings.GetSetting(Datamine.Setting.AutoLoadMapData) then
        C_AddOns.LoadAddOn(DATAMINE_MAPS);
    end
end);

EventUtil.ContinueOnAddOnLoaded(DATAMINE_MAPS, function()
    Datamine.EventRegistry:TriggerEvent(Datamine.Events.MAPVIEW_MAP_DATA_LOADED);
end);

------------

do
    local helpMessage = L.SLASH_CMD_SETTINGS_HELP;
    Datamine.Slash:RegisterCommand("settings", Datamine.Settings.OpenSettings, helpMessage, "Settings");
end