local L = Datamine.Strings;
local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

Datamine.Settings = {};

Datamine.Setting = {
    ChatPrefixColor = "ChatPrefixColor",
    debugTargetInfo = "debugTargetInfo",
    CollectCreatureData = "CollectCreatureData",
    SeenCreatureDataWarning = "SeenCreatureDataWarning",
    AutoLoadMapData = "AutoLoadMapData"
};

local defaultConfig = {
    [Datamine.Setting.ChatPrefixColor] = "FFF542F5",
    [Datamine.Setting.debugTargetInfo] = false,
    [Datamine.Setting.CollectCreatureData] = false,
    [Datamine.Setting.SeenCreatureDataWarning] = false,
    [Datamine.Setting.AutoLoadMapData] = false,
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

    if DatamineConfig.SeenCreatureDataWarning == nil then
        DatamineConfig.SeenCreatureDataWarning = false;
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

local category = Settings.RegisterVerticalLayoutCategory(Datamine.Constants.AddonName);

do
    local variable = Datamine.Setting.debugTargetInfo;
    local variableType = Settings.VarType.Boolean;
    local name = L.CONFIG_DEBUGTARGETINFO_NAME;
    local tooltip = L.CONFIG_DEBUGTARGETINFO_TOOLTIP;

    local setting = CreateCVarSetting(category, name, variable, variableType, defaultConfig[variable]);
    Settings.CreateCheckBox(category, setting, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);

    allSettings[variable] = setting;
end

do
    local variable = Datamine.Setting.CollectCreatureData;
    local variableType = Settings.VarType.Boolean;
    local name = L.CONFIG_CREATUREDATA_NAME;
    local tooltip = L.CONFIG_CREATUREDATA_TOOLTIP;

    local setting = Settings.RegisterAddOnSetting(category, name, variable, variableType, defaultConfig[variable]);
    Settings.CreateCheckBox(category, setting, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);

    allSettings[variable] = setting;
end

do
    local variable = Datamine.Setting.AutoLoadMapData;
    local variableType = Settings.VarType.Boolean;
    local name = L.CONFIG_AUTO_LOAD_MAP_DATA_NAME;
    local tooltip = L.CONFIG_AUTO_LOAD_MAP_DATA_TOOLTIP;

    local setting = Settings.RegisterAddOnSetting(category, name, variable, variableType, defaultConfig[variable]);
    Settings.CreateCheckBox(category, setting, tooltip);
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

------------

-- handler for the AutoLoadMapData config option
EventUtil.ContinueOnAddOnLoaded("Datamine", function()
    if Datamine.Settings.GetSetting(Datamine.Setting.AutoLoadMapData) then
        C_AddOns.LoadAddOn("Datamine_Maps");
    end
end);