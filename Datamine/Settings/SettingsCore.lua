local L = Datamine.Strings;
local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

Datamine.Settings = {};

Datamine.Settings.Keys = {
    ChatPrefixColor = "ChatPrefixColor",
    debugTargetInfo = "debugTargetInfo",
    CollectCreatureData = "CollectCreatureData",
    SeenCreatureDataWarning = "SeenCreatureDataWarning",
};

local defaultConfig = {
    [Datamine.Settings.Keys.ChatPrefixColor] = "FFF542F5",
    [Datamine.Settings.Keys.debugTargetInfo] = false,
    [Datamine.Settings.Keys.CollectCreatureData] = false,
    [Datamine.Settings.Keys.SeenCreatureDataWarning] = false,
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
    local variable = Datamine.Settings.Keys.debugTargetInfo;
    local variableType = Settings.VarType.Boolean;
    local name = L.CONFIG_DEBUGTARGETINFO_NAME;
    local tooltip = L.CONFIG_DEBUGTARGETINFO_TOOLTIP;

    local setting = CreateCVarSetting(category, name, variable, variableType, defaultConfig[variable]);
    Settings.CreateCheckBox(category, setting, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);

    allSettings[variable] = setting;
end

do
    local variable = Datamine.Settings.Keys.CollectCreatureData;
    local variableType = Settings.VarType.Boolean;
    local name = L.CONFIG_CREATUREDATA_NAME;
    local tooltip = L.CONFIG_CREATUREDATA_TOOLTIP;

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

local function ShowCreatureDataTogglePopup()
    if DatamineConfig.SeenCreatureDataWarning then
        return;
    end

    local title = L.POPUP_CONFIG_CREATUREDATA_TITLE;
    local text = L.POPUP_CONFIG_CREATUREDATA_TEXT;
    local callback = function(choice)
        DatamineConfig.SeenCreatureDataWarning = true;
        allSettings.CollectCreatureData:SetValue(choice);
    end;

    DataminePopupBox:ShowPopup(title, text, callback);
end

--EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", ShowCreatureDataTogglePopup);