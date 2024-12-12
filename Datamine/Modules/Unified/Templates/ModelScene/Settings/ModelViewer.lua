local L = Datamine.Strings;
local S = Datamine.Settings;

local parentCategory = S.GetTopLevelCategory();
local category = Settings.RegisterVerticalLayoutSubcategory(parentCategory, L.CONFIG_CATEGORY_MODELVIEWER);

do
    local variable = "ModelViewerBackgroundColor";
    local name = L.CONFIG_MODELVIEWER_BG_COLOR_NAME;
    local tooltip = L.CONFIG_MODELVIEWER_BG_COLOR_TOOLTIP;
    local default = DatamineVeryLightGray:GenerateHexColor();

    local setting = S.RegisterSetting(category, variable, name, default);
    S.CreateColorPickerButton(category, setting, name, tooltip);
end

------------

function S.GetModelViewerBackgroundColor()
    return CreateColorFromRGBHexString(S.GetSetting("ModelViewerBackgroundColor"));
end