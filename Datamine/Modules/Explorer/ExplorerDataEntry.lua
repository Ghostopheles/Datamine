DatamineExplorerDataEntryMixin = {};

function DatamineExplorerDataEntryMixin:Init(data, parent)
    self:SetParent(parent);
    self.KeyText = self:CreateFontString(nil, nil, "GameFontHighlight");
    self.KeyText:SetPoint("TOPLEFT");
    self.KeyText:SetPoint("BOTTOMRIGHT", self, "CENTER");
    self.KeyText:SetJustifyH("LEFT");
    self.KeyText:SetText(data.key .. ":");
    self.KeyText:SetTextScale(1.3);

    self.ValueText = self:CreateFontString(nil, nil, "GameFontHighlight");
    self.ValueText:SetPoint("TOPRIGHT");
    self.ValueText:SetPoint("BOTTOMLEFT", self, "CENTER");
    self.ValueText:SetText(data.value);
    self.ValueText:SetTextScale(1.3);

    if data.key == "Hyperlink" then
        self:GetParent().Icon:SetItem(data.value);
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