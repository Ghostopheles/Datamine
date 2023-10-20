local Print = function(...) Datamine.Print("ModelView", ...) end;

DatamineModelFrameMixin = CreateFromMixins(DressUpModelFrameMixin, CallbackRegistryMixin);

local MODES = {
    ModelScene = 1,
    PlayerModel = 2,
};

function DatamineModelFrameMixin:OnLoad()
    self:SetTitle("Datamine Model Viewer");
    self:SetSize(800, 1000);
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

    if DevTool then
        C_Timer.After(1, function() DevTool:AddData(DatamineDressUpFrame.ModelScene, "DatamineModelScene"); end);
    end

    self.ViewingMode = MODES.ModelScene;
end

function DatamineModelFrameMixin:OnShow()
    SetPortraitTexture(DatamineDressUpFramePortrait, "player");
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
    self:SetupPlayerModel();
    self:SetViewingMode(MODES.ModelScene);
    self.ModelScene.ControlFrame:SetModelScene(self.ModelScene);
end

function DatamineModelFrameMixin:SetZoomLevels()
    local modelScene = self.ModelScene;

    if modelScene:HasActiveCamera() then
        local activeCamera = modelScene:GetActiveCamera();
        activeCamera:SetMinZoomDistance(1);
        activeCamera:SetMaxZoomDistance(10);
    end
end

function DatamineModelFrameMixin:ToggleControlPanel()
    local show = not self.ControlPanel:IsShown();
    self.ControlPanel:SetShown(show);
end

function DatamineModelFrameMixin:OnPlayerModelActivated()
    self.ModelScene:Hide();
    self.PlayerModel:Show();
    self.ControlPanel.Pages.PlayerModelPage:Show();
    self.ControlPanel.Pages.ModelScenePage:Hide();
end

function DatamineModelFrameMixin:OnModelSceneActivated()
    self.ModelScene:Show();
    self.PlayerModel:Hide();
    self.ControlPanel.Pages.ModelScenePage:Show();
    self.ControlPanel.Pages.PlayerModelPage:Hide();
end

function DatamineModelFrameMixin:SetViewingMode(newMode)
    if newMode == MODES.PlayerModel then
        self:OnPlayerModelActivated();
    elseif newMode == MODES.ModelScene then
        self:OnModelSceneActivated();
    end

    self.ViewingMode = newMode;
end

function DatamineModelFrameMixin:GetActor()
    if self.ViewingMode == MODES.PlayerModel then
        return self.PlayerModel;
    elseif self.ViewingMode == MODES.ModelScene then
        return self.ModelScene:GetPlayerActor();
    end
end

function DatamineModelFrameMixin:ResetEntryBoxes()
    self.ControlPanel.ModelFileIDEntry:SetText("");
    self.ControlPanel.CDisplayInfoIDEntry:SetText("");
end

function DatamineModelFrameMixin:SetupPlayerModel()
    local playerModel = self.PlayerModel;
    if not playerModel then
        playerModel = CreateFrame("PlayerModel", nil, self, "DataminePlayerModelTemplate");
        playerModel:SetAllPoints(self.Inset);
    end

    self.PlayerModel = playerModel;

    if DevTool then
        C_Timer.After(0, function() DevTool:AddData(self.PlayerModel, "DataminePlayerModel") end);
    end
end

function DatamineModelFrameMixin:SetCreature(creatureID, displayID)
    local actor = self:GetActor();

    if not actor then return end;

    creatureID = strtrim(creatureID);
    displayID = strtrim(displayID);

    if displayID == "" and creatureID == "" then
        actor:ResetModel();
        return;
    elseif displayID == "" then
        displayID = nil;
    end

    return actor:SetCreature(creatureID, displayID);
end

function DatamineModelFrameMixin:SetModelFromTarget()
    local actor = self:GetActor();

    if not actor then return end;

    local unit = "target";
    if self.ViewingMode == MODES.ModelScene then
        return actor:SetModelByUnit(unit);
    elseif self.ViewingMode == MODES.PlayerModel then
        return actor:SetUnit(unit);
    end
end

function DatamineModelFrameMixin:ToggleSceneMode()
    if self.ViewingMode == MODES.ModelScene then
        self:SetViewingMode(MODES.PlayerModel);
    elseif self.ViewingMode == MODES.PlayerModel then
        self:SetViewingMode(MODES.ModelScene);
    end
end

function DatamineModelFrameMixin:ToggleSheathed(override)
    local actor = self:GetActor();
    if override then
        actor:SetSheathed(override);
    end
    actor:SetSheathed(not actor:GetSheathed());
end

function DatamineModelFrameMixin:SetDressState(dressed)
    local actor = self:GetActor();
    if dressed then
        actor:Dress()
    else
        actor:Undress()
    end
end

function DatamineModelFrameMixin:SetModelByFileID(fdid, enableMips)
    local actor = self:GetActor();

    if not actor then return end;
    fdid = strtrim(fdid);
    return actor:SetModelByFileID(tonumber(fdid), enableMips);
end

function DatamineModelFrameMixin:SetModelByCreatureDisplayID(displayID)
    local actor = self:GetActor();

    if not actor then return end;
    displayID = strtrim(displayID);
    return actor:SetModelByCreatureDisplayID(tonumber(displayID));
end

function DatamineModelFrameMixin:ApplySpellVisualKit(spellVisualKitID, loop)
    local actor = self:GetActor();
    if not actor then return end;

    loop = loop or false;
    spellVisualKitID = strtrim(spellVisualKitID);

    actor:SetSpellVisualKit(tonumber(spellVisualKitID), loop);
    return true;
end

function DatamineModelFrameMixin:PlayAnimationKit(animationKitID, loop)
    local actor = self:GetActor();
    if not actor then return end;

    loop = loop or true;
    animationKitID = strtrim(animationKitID);

    if animationKitID == "" then
        if self.ViewingMode == MODES.ModelScene then
            actor:StopAnimationKit();
        elseif self.ViewingMode == MODES.PlayerModel then
            actor:StopAnimKit();
        end
        return true;
    end

    if self.ViewingMode == MODES.ModelScene then
        actor:PlayAnimationKit(tonumber(animationKitID), loop);
    elseif self.ViewingMode == MODES.PlayerModel then
        actor:PlayAnimKit(tonumber(animationKitID), loop);
    end
    return true;
end