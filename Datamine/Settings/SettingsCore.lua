local defaultConfig = {
    ChatPrefixColor = "FFF542F5";
    debugTargetInfo = false;
};

local allSettings = {};

local function InitSavedVariables()
    if not DatamineConfig then
        DatamineConfig = CopyTable(defaultConfig);
    end

    for name, setting in pairs(allSettings) do
        local var = DatamineConfig[name];

        if not var then
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
end

local function ShowColorPicker(r, g, b, a, callback)
    assert(r and g and b, "Invalid RGB values passes to ShowColorPicker");
    local colorPicker = ColorPickerFrame;
    local selectedColor = CreateColor(r, g, b, a);
    local selectedColorRGB = {selectedColor:GetRGB()};

    colorPicker.hasOpacity, colorPicker.opacity = (a ~= nil), a;
    colorPicker.previousValues = selectedColorRGB;

    if callback and type(callback) == "function" then
        colorPicker.func, colorPicker.opacityFunc, colorPicker.cancelFunc = callback, callback, callback;
    else
        colorPicker.func, colorPicker.opacityFunc, colorPicker.cancelFunc = OnSettingChanged, OnSettingChanged, OnSettingChanged;
    end

    colorPicker:SetColorRGB(unpack(selectedColorRGB));
    colorPicker:Hide();
    colorPicker:Show();
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
    local variable = "debugTargetInfo";
    local variableType = Settings.VarType.Boolean;
    local name = "Enable barber shop debug tooltips";
    local tooltip = "Enables the display of debug tooltips in the barber shop and on character customization screens.";

    local setting = CreateCVarSetting(category, name, variable, variableType, defaultConfig[variable]);
    Settings.CreateCheckBox(category, setting, tooltip);
    Settings.SetOnValueChangedCallback(variable, OnSettingChanged);

    allSettings[variable] = setting;
end

Settings.RegisterAddOnCategory(category)