Datamine.Events = {
    MODEL_RESET = "ModelReset",
    MODEL_LOADED = "ModelLoaded",
    MODEL_LOADED_INTERNAL = "ModelLoadedInternal",
    MODEL_VIEW_MODE_CHANGED = "ModelViewModeChanged",
    MODEL_CONTROLS_DEFAULTS_UPDATED = "ModelControlsDefaultsUpdated",
    MODEL_OUTFIT_UPDATED = "ModelOutfitUpdated",
    MODEL_DRESSED = "ModelDressed",
    MODEL_CONTROLS_TAB_COLLAPSED = "ModelControlsTabCollapsed",
    SEARCH_MODE_CHANGED = "SearchModeChanged",
    SEARCH_RESULT = "SearchResult",
    SEARCH_BEGIN = "SearchBegin",
    WORKSPACE_MODE_CHANGED = "WorkspaceModeChanged",
    UI_MAIN_HIDE = "UIMainHide",
    SETTING_CHANGED = "SettingChanged",
    MAPVIEW_MAP_CHANGED = "MapViewMapChanged",
    MAPVIEW_MAP_LOADED = "MapViewMapLoaded"
};

local function GenerateCallbackEvents()
    local tbl = {};
    for _, v in pairs(Datamine.Events) do
        tinsert(tbl, v);
    end

    return tbl;
end

Datamine.EventRegistry = CreateFromMixins(CallbackRegistryMixin);
Datamine.EventRegistry:OnLoad();
Datamine.EventRegistry:GenerateCallbackEvents(GenerateCallbackEvents());