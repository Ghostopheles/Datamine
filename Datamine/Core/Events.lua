Datamine.Events = {
    MODEL_RESET = "ModelReset",
    MODEL_LOADED = "ModelLoaded",
    MODEL_LOADED_INTERNAL = "ModelLoadedInternal",
    MODEL_VIEW_MODE_CHANGED = "ModelViewModeChanged",
    MODEL_CONTROLS_DEFAULTS_UPDATED = "ModelControlsDefaultsUpdated",
    MODEL_CONTROLS_TRANSMOG_SET_ITEM_SELECTED = "ModelControlsTransmogSetItemSelected",
    MODEL_OUTFIT_UPDATED = "ModelOutfitUpdated",
    MODEL_DRESSED = "ModelDressed",
    SEARCH_MODE_CHANGED = "SearchModeChanged",
    SEARCH_RESULT = "SearchResult",
    SEARCH_BEGIN = "SearchBegin",
    WORKSPACE_MODE_CHANGED = "WorkspaceModeChanged",
    UI_MAIN_HIDE = "UIMainHide",
    SETTING_CHANGED = "SettingChanged",
    MAPVIEW_MAP_CHANGED = "MapViewMapChanged",
    MAPVIEW_MAP_LOADED = "MapViewMapLoaded",
    MAPVIEW_MAP_DATA_LOADED = "MapViewMapDataLoaded",
    MAPVIEW_RIGHT_CLICK = "MapViewRightClick",
    CREATUREVIEW_CREATURE_LOADED = "CreatureViewCreatureLoaded"
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

Datamine.Callbacks = {};

local PrivateRegistries = {};

---Provides a way to create private callback registries
---@param name? string
---@param events? table<string> | table<string, string>
---@return CallbackRegistryMixin registry
function Datamine.Callbacks.NewRegistry(name, events)
    assert(not PrivateRegistries[name], "Private registry with that name already exists");
    local registry = CreateFromMixins(CallbackRegistryMixin);

    if type(events) == "table" then
        local _events = {};
        for _, eventName in pairs(events) do
            tinsert(_events, eventName);
        end
        registry:GenerateCallbackEvents(_events);
    else
        registry:SetUndefinedEventsAllowed(true);
    end

    registry:OnLoad();

    -- if name is not provided, it'll be entirely ephemeral
    if type(name) == "string" then
        PrivateRegistries[name] = registry;
    end

    return registry;
end

---Wrapper for NewRegistry that doesn't include name as the first argument
---@param events? table<string> | table<string, string>
---@return CallbackRegistryMixin registry
function Datamine.Callbacks.NewAnonymousRegistry(events)
    return Datamine.Callbacks.NewRegistry(nil, events);
end

---Returns a cached private callback registry
---@param name string
function Datamine.Callbacks.GetRegistryByName(name)
    return PrivateRegistries[name];
end