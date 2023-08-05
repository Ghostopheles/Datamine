local function InitSavedVariables()
    if not DatamineConfig then
        DatamineConfig = {
            ChatPrefixColor = "FFF542F5";
        };
    end

    Datamine.Constants.ChatPrefixColor = CreateColorFromHexString(DatamineConfig.ChatPrefixColor);
end

EventUtil.RegisterOnceFrameEventAndCallback("ADDON_LOADED", InitSavedVariables, "Datamine");

local function OnSettingChanged(_, setting, value)
	local variable = setting:GetVariable()
	DatamineConfig[variable] = value
end

function ShowColorPicker(r, g, b, a, callback)
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

local category = Settings.RegisterVerticalLayoutCategory(Datamine.Constants.AddonName);

Settings.RegisterAddOnCategory(category)