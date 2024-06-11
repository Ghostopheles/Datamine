local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

local OWNED_ATLAS = "common-icon-checkmark";
local UNOWNED_ATLAS = "common-icon-redx";

DatamineModelControlsTransmogSetItemEntryMixin = {};

function DatamineModelControlsTransmogSetItemEntryMixin:OnLoad()
    Registry:RegisterCallback(Events.MODEL_CONTROLS_TRANSMOG_SET_ITEM_SELECTED, self.OnItemSelected, self);
end

function DatamineModelControlsTransmogSetItemEntryMixin:Init(node)
    self.Data = node:GetData();
    self:SetText(self.Data.Text);
    self:SetOwned(self.Data.IsOwned);
    self:SetSelected(self.Data.IsSelected);
end

function DatamineModelControlsTransmogSetItemEntryMixin:SetText(text)
    self.Text:SetText(text);
end

function DatamineModelControlsTransmogSetItemEntryMixin:SetOwned(isOwned)
    local icon = isOwned and OWNED_ATLAS or UNOWNED_ATLAS;
    self.Icon:SetAtlas(icon);
end

function DatamineModelControlsTransmogSetItemEntryMixin:SetSelected(isSelected)
    self.SelectedHighlight:SetShown(isSelected);
    self.IsSelected = isSelected;
end

function DatamineModelControlsTransmogSetItemEntryMixin:OnItemSelected(invSlot, sourceID)
    if invSlot ~= self.Data.InvSlot then
        return;
    end
    self:SetSelected(sourceID == self.Data.SourceID);
end