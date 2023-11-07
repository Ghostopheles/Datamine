DatamineExplorerDataEntryMixin = {};

function DatamineExplorerDataEntryMixin:Init(data, parent)
    self:SetParent(parent);
    self.KeyText = self:CreateFontString(nil, nil, "GameFontHighlight");
    self.KeyText:SetPoint("TOPLEFT");
    self.KeyText:SetPoint("BOTTOMRIGHT", self, "BOTTOM");
    self.KeyText:SetJustifyH("LEFT");
    self.KeyText:SetText(data.key .. ":");

    self.KeyText:SetHeight(parent:GetHeight());
    self.KeyText:SetTextScale(1.2);
    self.KeyText:SetJustifyV("CENTER");

    self.ValueText = self:CreateFontString(nil, nil, "GameFontHighlight");
    self.ValueText:SetPoint("TOPRIGHT");
    self.ValueText:SetPoint("BOTTOMLEFT", self, "BOTTOM");
    self.ValueText:SetText(data.value);

    self.ValueText:SetHeight(parent:GetHeight());
    self.ValueText:SetTextScale(1.2);
    self.ValueText:SetJustifyV("CENTER");

    if self.ValueText:IsTruncated() then
        self.ValueText:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.ValueText, "ANCHOR_CURSOR");
            GameTooltip:SetText(self.ValueText:GetText(), 1, 1, 1);
            GameTooltip:Show();
        end);

        self.ValueText:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end);
    end

    if data.key == "Hyperlink" and data.type == DatamineExplorerDataTypes.Item then
        self:GetParent().Icon:SetItem(data.value);
    end

    if data.key == "Icon" and data.type == DatamineExplorerDataTypes.Spell then
        self:GetParent().Icon.icon:SetTexture(data.value);
    end

    self:SetScript("OnEnter", self.OnEnter);
    self:SetScript("OnLeave", self.OnLeave);
end

function DatamineExplorerDataEntryMixin:SetDefaultAlpha(number)
    self.bg:SetColorTexture(0.25, 0.25, 0.25, number);
    self.DefaultAlpha = number;
end

function DatamineExplorerDataEntryMixin:OnEnter()
    self.bg:SetColorTexture(0.5, 0.5, 0.5, 0.5);
end

function DatamineExplorerDataEntryMixin:OnLeave()
    self.bg:SetColorTexture(0.25, 0.25, 0.25, self.DefaultAlpha or 0.35);
end