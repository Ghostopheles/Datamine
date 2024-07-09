local L = Datamine.Strings;

local function CreateFontString(parent)
    local fontString = parent:CreateFontString(nil, "OVERLAY", "DatamineCleanFontSmall");
    fontString:SetJustifyH("CENTER");
    fontString:SetJustifyV("MIDDLE");
    return fontString;
end

local function CreatePreviewFrameTextStack(parent)
    local container = CreateFrame("Frame", nil, parent, "VerticalLayoutFrame");
    container.spacing = 5;

    container.ModelSceneID = CreateFontString(container);
    container.ModelSceneID.layoutIndex = 1;

    container.DisplayID = CreateFontString(container);
    container.DisplayID.layoutIndex = 2;

    container.FileDataID = CreateFontString(container);
    container.FileDataID.layoutIndex = 3;

    container:SetPoint("TOPRIGHT", -10, -10);
    return container;
end

local function OnModelPreviewShow(display)
    if not display.ModelInfoContainer then
        display.ModelInfoContainer = CreatePreviewFrameTextStack(display);
    end

    local container = display.ModelInfoContainer;

    if not Datamine.Settings.GetSetting(Datamine.Setting.ShowModelInfo) then
        container:SetAlpha(0);
    else
        container:SetAlpha(1);
    end

    local msid = container.ModelSceneID;
    local cdid = container.DisplayID;
    local fdid = container.FileDataID;

    msid:SetText(format(L.MODEL_INFO_MODEL_SCENE_ID_FORMAT, display.modelSceneID or L.GENERIC_NA));
    cdid:SetText(format(L.MODEL_INFO_DISPLAY_ID_FORMAT, display.displayID or L.GENERIC_NA));

    local actor;
    for activeActor in display.ModelScene:EnumerateActiveActors() do
        actor = activeActor;
        break;
    end

    fdid:SetText(format(L.MODEL_INFO_FILEDATAID_FORMAT, actor:GetModelFileID() or L.GENERIC_NA));

    container:MarkDirty();
end

local function OnModelPreviewHide(display)
    if not display.ModelInfoContainer then
        return;
    end

    local container = display.ModelInfoContainer;
    local msid = container.ModelSceneID;
    local cdid = container.DisplayID;
    local fdid = container.FileDataID;

    local placeholder = L.GENERIC_NA;

    msid:SetText(format(L.MODEL_INFO_MODEL_SCENE_ID_FORMAT, placeholder));
    cdid:SetText(format(L.MODEL_INFO_DISPLAY_ID_FORMAT, placeholder));
    fdid:SetText(format(L.MODEL_INFO_FILEDATAID_FORMAT, placeholder));

    container:MarkDirty();
end

local function HookFrames()
    ModelPreviewFrame.Display:HookScript("OnShow", OnModelPreviewShow);
    ModelPreviewFrame.Display:HookScript("OnHide", OnModelPreviewHide);
end

local function OnSettingChanged(_, setting, value)
    if setting == Datamine.Setting.ShowModelInfo then
        if ModelPreviewFrame:IsShown() then
            local container = ModelPreviewFrame.Display.ModelInfoContainer;
            if not container then return; end;
            local alpha = value and 1 or 0;
            container:SetAlpha(alpha);
        end
    end
end

Datamine.EventRegistry:RegisterCallback(Datamine.Events.SETTING_CHANGED, OnSettingChanged);

EventUtil.RegisterOnceFrameEventAndCallback("FIRST_FRAME_RENDERED", HookFrames);

-- TODO: handle carousels