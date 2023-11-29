local moduleName = "ExplorerTooltip"
local Print = function(...) Datamine.Print(moduleName, ...) end;

DatamineExplorerTooltipFrameMixin = {};

function DatamineExplorerTooltipFrameMixin:OnLoad()
    self.minimumWidth = 150;
    self.minimumHeight = 150;

    self:SetSize(self.minimumWidth, self.minimumHeight);

    ButtonFrameTemplate_HidePortrait(self);
    self.CloseButton:Hide();
end

function DatamineExplorerTooltipFrameMixin:SetHyperlink(hyperlink)
    self.Tooltip:SetOwner(self);
    self.Tooltip:SetHyperlink(hyperlink);
    self.Tooltip:Show();
    self:MarkDirty();
end