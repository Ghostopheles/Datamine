DatamineModelFrameMixin = CreateFromMixins(DressUpModelFrameMixin);

function DatamineModelFrameMixin:OnLoad()
    self:SetTitle("Datamine Model Viewer");
    self:SetSize(600, 800);
    self:ClearAllPoints();
    self:SetPoint("CENTER");

    self:SetMovable(true);
    self.TitleContainer:RegisterForDrag("LeftButton");
    self.TitleContainer:SetScript("OnMouseDown", function()
        self:StartMoving();
    end);
    self.TitleContainer:SetScript("OnMouseUp", function()
        self:StopMovingOrSizing();
    end);
end

function DatamineModelFrameMixin:OnShow()
    SetPortraitTexture(DatamineDressUpFramePortrait, "player");
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function DatamineModelFrameMixin:ToggleControlPanel()
    local show = not self.ControlPanel:IsShown();
    self.ControlPanel:SetShown(show);
end

function DatamineModelFrameMixin:SetDressState(dressed)
    local actor = self.ModelScene:GetPlayerActor();
    local dress = (tostring(dressed) == "1");
    if dress then
        actor:Dress()
    else
        actor:Undress()
    end
end

DatamineModelFrameControlPanelMixin = CreateFromMixins(DressUpOutfitDetailsPanelMixin);

local CLASS_BACKGROUND_SETTINGS = {
	["DEFAULT"] = { desaturation = 0.5, alpha = 0.25 },
	["DEATHKNIGHT"] = { desaturation = 0.5, alpha = 0.30 },
	["DEMONHUNTER"] = { desaturation = 0.5, alpha = 0.30 },
	["HUNTER"] = { desaturation = 0.5, alpha = 0.45 },
	["MAGE"] = { desaturation = 0.5, alpha = 0.45 },
	["PALADIN"] = { desaturation = 0.5, alpha = 0.21 },
	["ROGUE"] = { desaturation = 0.5, alpha = 0.65 },
	["SHAMAN"] = { desaturation = 0.5, alpha = 0.40 },
	["WARLOCK"] = { desaturation = 0.5, alpha = 0.40 },	
}

function DatamineModelFrameControlPanelMixin:OnLoad()
	local frameLevel = self:GetParent().NineSlice:GetFrameLevel();
	self:SetFrameLevel(frameLevel + 1);

    -- maybe set visual kit
    -- set model from display ID
    -- set model from file ID

    local parent = self:GetParent();
    local controlPanel = parent.ControlPanel;
    local modelScene = parent.ModelScene;
    local buttonWidth = 128;
    local editBoxWidth = 175;

    do -- header
        local header = controlPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        header:SetPoint("TOP", self, 0, -25);
        header:SetText("Model Controls");
        header:SetTextScale(1.3);
        header:SetTextColor(1, 1, 1, 1);
    end

    do -- dress state toggles
        local a = CreateFrame("Button", nil, controlPanel, "UIPanelButtonTemplate");
        a:SetPoint("TOPLEFT", controlPanel, 25, -50);
        a:SetWidth(buttonWidth / 1.35);
        a:SetText("Dress");
        a:RegisterForClicks("AnyUp");
        a:SetScript("OnClick", function() modelScene:GetPlayerActor():Dress() end);

        local b = CreateFrame("Button", nil, controlPanel, "UIPanelButtonTemplate");
        b:SetPoint("LEFT", a, "RIGHT", 10, 0);
        b:SetWidth(buttonWidth / 1.35);
        b:SetText("Undress");
        b:RegisterForClicks("AnyUp");
        b:SetScript("OnClick", function() modelScene:GetPlayerActor():Undress() end);

        controlPanel.DressButton = a;
        controlPanel.UndressButton = b;
    end

    do -- set model by file ID
        local fileIDEntryBox = CreateFrame("EditBox", nil, controlPanel, "SearchBoxTemplate");
        fileIDEntryBox:SetPoint("TOPLEFT", controlPanel.DressButton, "BOTTOMLEFT", 5, -15);
        fileIDEntryBox:SetPoint("TOPRIGHT", controlPanel.UndressButton, "BOTTOMRIGHT", 0, -15);
        fileIDEntryBox:SetHeight(35);
        fileIDEntryBox.Instructions:SetText("Set model by file ID...");

        controlPanel.ModelFileIDEntry = fileIDEntryBox;
    end
end

function DatamineModelFrameControlPanelMixin:Refresh()
end