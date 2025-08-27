DatamineColorSwatchSettingMixin = {};

function DatamineColorSwatchSettingMixin:OnLoad()
    SettingsListElementMixin.OnLoad(self);
end

function DatamineColorSwatchSettingMixin:Init(initializer)
    SettingsListElementMixin.Init(self, initializer);

    local data = initializer:GetData();
    local color = data.setting:GetValue();
    local colorObj = CreateColorFromHexString(color);
    self.ColorSwatch:SetColor(colorObj);

    self.ColorSwatch:SetScript("OnClick", function()
        local info = {};
        local currentColor = CreateColorFromHexString(data.setting:GetValue());
        info.r, info.g, info.b, info.a = currentColor:GetRGBA();
        info.swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB();
            local a = ColorPickerFrame:GetColorAlpha();
            self.ColorSwatch.Color:SetVertexColor(r, g, b);

            local newColor = CreateColor(r, g, b, a);
            data.setting:SetValue(newColor:GenerateHexColor());
        end;

        info.cancelFunc = function ()
            local r, g, b, a = ColorPickerFrame:GetPreviousValues();
            self.ColorSwatch.Color:SetVertexColor(r, g, b);

            local newColor = CreateColor(r, g, b, a);
            data.setting:SetValue(newColor:GenerateHexColor());
        end;

        ColorPickerFrame:SetupColorPickerAndShow(info);
    end);
end