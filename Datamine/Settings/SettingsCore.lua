local L = Datamine.Strings;
local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

local CreateCheckbox = Settings.CreateCheckbox or Settings.CreateCheckBox;

Datamine.Settings = {};

Datamine.Setting = {
    ChatPrefixColor = "ChatPrefixColor",
    debugTargetInfo = "debugTargetInfo", -- this one is a cvar, hence the weird capitalization
    CollectCreatureData = "CollectCreatureData",
    AutoLoadMapData = "AutoLoadMapData",
    -- will also include all settings registered externally
};

local defaultConfig = {
    [Datamine.Setting.ChatPrefixColor] = "FFF542F5",
    [Datamine.Setting.debugTargetInfo] = false,
    [Datamine.Setting.CollectCreatureData] = false,
    [Datamine.Setting.AutoLoadMapData] = false,
    -- will also include all settings registered externally
};

local allSettings = {};

local function InitSavedVariables()
    if not DatamineConfig then
        DatamineConfig = CopyTable(defaultConfig);
    end

    for name, setting in pairs(allSettings) do
        local var = DatamineConfig[name];

        if var == nil then
            DatamineConfig[name] = setting:GetValue();
        else
            setting:SetValue(DatamineConfig[name]);
        end
    end

    Datamine.Constants.ChatPrefixColor = CreateColorFromHexString(DatamineConfig.ChatPrefixColor);
end

EventUtil.ContinueOnAddOnLoaded("Datamine", InitSavedVariables);

local function OnSettingChanged(_, setting, value)
	local variable = setting:GetVariable()
	DatamineConfig[variable] = value
    Registry:TriggerEvent(Events.SETTING_CHANGED, variable, value);
end

local function CreateCVarSetting(category, name, variable, variableType, defaultValue)
    local setting = Settings.RegisterAddOnSetting(category, name, variable, variableType, defaultValue);

    local cvarAccessor = CreateCVarAccessor(variable, variableType);
    setting.GetValueInternal = function(self)
		return cvarAccessor:GetValue();
	end;

	setting.SetValueInternal = function(self, value)
		assert(type(value) == variableType);
		self.pendingValue = value;
		cvarAccessor:SetValue(value);
		self.pendingValue = nil;
		return value;
	end

	setting.GetDefaultValueInternal = function(self)
		return cvarAccessor:GetDefaultValue();
	end

	setting.ConvertValueInternal = function(self, value)
		return cvarAccessor:ConvertValue(value);
	end

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
        opacityFunc = Datamine.Utils.Debounce(0.1, OnColorChanged),
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

    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue);
    allSettings[variable] = setting;

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
    local initializer = Settings.CreateElementInitializer("SettingsListSectionHeaderTemplate", { name = name});
    local layout = SettingsPanel:GetLayout(category);
    layout:AddInitializer(initializer);

    return initializer;
end

Datamine.Settings.CreateHeader = CreateHeader;

local function CreateCheckboxForSetting(category, setting, tooltip)
    CreateCheckbox(category, setting, tooltip);

    local variable = setting:GetVariable();
    allSettings[variable] = setting;
end

Datamine.Settings.CreateCheckbox = CreateCheckboxForSetting;

------------

local category = Settings.RegisterVerticalLayoutCategory(Datamine.Constants.AddonName);

do
    local variable = Datamine.Setting.ChatPrefixColor;
    local variableType = Settings.VarType.String;
    local name = L.CONFIG_CHAT_PREFIX_COLOR_NAME;
    local tooltip = L.CONFIG_CHAT_PREFIX_COLOR_TOOLTIP;

    local setting = Settings.RegisterAddOnSetting(category, name, variable, variableType, defaultConfig[variable]);

    CreateColorPickerButtonForSetting(category, setting, name, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);

    allSettings[variable] = setting;
end

do
    local variable = Datamine.Setting.debugTargetInfo;
    local variableType = Settings.VarType.Boolean;
    local name = L.CONFIG_DEBUGTARGETINFO_NAME;
    local tooltip = L.CONFIG_DEBUGTARGETINFO_TOOLTIP;

    local setting = CreateCVarSetting(category, name, variable, variableType, defaultConfig[variable]);
    CreateCheckbox(category, setting, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);

    allSettings[variable] = setting;
end

do
    local variable = Datamine.Setting.CollectCreatureData;
    local variableType = Settings.VarType.Boolean;
    local name = L.CONFIG_CREATUREDATA_NAME;
    local tooltip = L.CONFIG_CREATUREDATA_TOOLTIP;

    local setting = Settings.RegisterAddOnSetting(category, name, variable, variableType, defaultConfig[variable]);
    CreateCheckbox(category, setting, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);

    allSettings[variable] = setting;
end

do
    local variable = Datamine.Setting.AutoLoadMapData;
    local variableType = Settings.VarType.Boolean;
    local name = L.CONFIG_AUTO_LOAD_MAP_DATA_NAME;
    local tooltip = L.CONFIG_AUTO_LOAD_MAP_DATA_TOOLTIP;

    local setting = Settings.RegisterAddOnSetting(category, name, variable, variableType, defaultConfig[variable]);
    CreateCheckbox(category, setting, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);

    allSettings[variable] = setting;
end

Settings.RegisterAddOnCategory(category);

------------

function Datamine.Settings.GetSetting(name)
    if allSettings[name] then
        return allSettings[name]:GetValue();
    end
end

function Datamine.Settings.GetColor(name)
    if allSettings[name] then
        return CreateColorFromHexString(allSettings[name]:GetValue());
    end
end

function Datamine.Settings.GetTopLevelCategory()
    return category;
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