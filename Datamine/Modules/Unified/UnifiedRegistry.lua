Datamine.Events = {
    VIEW_MODE_CHANGED = "ViewModeChanged",
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