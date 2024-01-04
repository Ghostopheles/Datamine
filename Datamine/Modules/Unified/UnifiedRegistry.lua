Datamine.Events = {
    MODEL_RESET = "ModelReset",
    MODEL_LOADED = "ModelLoaded",
    MODEL_LOADED_INTERNAL = "ModelLoadedInternal",
    MODEL_VIEW_MODE_CHANGED = "ModelViewModeChanged",
    MODEL_CONTROLS_DEFAULTS_UPDATED = "ModelControlsDefaultsUpdated",
    MODEL_OUTFIT_UPDATED = "ModelOutfitUpdated",
    SEARCH_MODE_CHANGED = "SearchModeChanged",
    SEARCH_RESULT = "SearchResult",
    SEARCH_BEGIN = "SearchBegin",
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