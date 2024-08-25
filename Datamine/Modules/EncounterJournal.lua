local EJ = {};

function EJ.GetViewedEncounterID()
    return EncounterJournal.encounterID;
end

------

local function OnBossButtonEnter(self)
    local Tooltips = Datamine.Tooltips;
    if not Tooltips.Begin(GameTooltip) then
        return;
    end

    local data = self:GetData();
    GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");

    Tooltips.Append("EncounterID", data.bossID);

    GameTooltip:Show();
    Tooltips.End();
end

local function OnBossButtonLeave(self)
    GameTooltip:Hide();
end

local function OnBossButtonAcquired(_, frame)
    if frame.DM_TOOLTIP then
        return;
    end

    frame:HookScript("OnEnter", OnBossButtonEnter);
    frame:HookScript("OnLeave", OnBossButtonLeave);

    frame.DM_TOOLTIP = true;
end

------

local function OnInstanceButtonEnter(self)
    local Tooltips = Datamine.Tooltips;
    if not Tooltips.Begin(GameTooltip) then
        return;
    end

    local data = self:GetData();
    GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");

    Tooltips.Append("InstanceID", data.instanceID);
    Tooltips.Append("MapID", data.mapID);

    GameTooltip:Show();
    Tooltips.End();
end

local function OnInstanceButtonLeave(self)
    GameTooltip:Hide();
end

local function OnInstanceButtonAcquired(_, frame)
    if frame.DM_TOOLTIP then
        return;
    end

    frame:HookScript("OnEnter", OnInstanceButtonEnter);
    frame:HookScript("OnLeave", OnInstanceButtonLeave);

    frame.DM_TOOLTIP = true;
end

local function OnEncounterJournalLoaded()
    Datamine.Utils.AddToDevTool(EncounterJournal, "EncounterJournal");

    local info = EncounterJournal.encounter.info;

    ScrollUtil.AddAcquiredFrameCallback(info.BossesScrollBox, OnBossButtonAcquired, nil, true);
    ScrollUtil.AddAcquiredFrameCallback(EncounterJournal.instanceSelect.ScrollBox, OnInstanceButtonAcquired, nil, true);
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_EncounterJournal", OnEncounterJournalLoaded);

------------

Datamine.EncounterJournal = EJ;