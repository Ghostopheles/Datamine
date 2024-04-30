local Callbacks = Datamine.Callbacks;

Datamine.Search = {};
Datamine.Search.Models = {};

local function GenerateSearchableString(str)
	return strlower(string.trim((string.gsub(str, "%p+", " "))));
end

------------

---@enum DatamineSearchState
local SEARCH_STATE = {
    PENDING = 1,
    RUNNING = 2,
    FINISHED = 3,
};

---@class DatamineSearchTaskProgress
---@field Found number
---@field Searched number
---@field Total number

---@class DatamineSearchTask
---@field Callbacks CallbackRegistryMixin
---@field State DatamineSearchState
---@field Ticker unknown
---@field Source table
---@field Query string
---@field Found number
---@field Searched number
---@field Total number?
---@field Step number
---@field Results table<number>
local DatamineSearchTask = {};

local EVENTS = {
    STATE_CHANGED = "SearchStateChanged",
    RESULTS_CHANGED = "SearchResultsChanged",
    PROGRESS_CHANGED = "SearchProgressChanged",
    QUERY_CHANGED = "SearchQueryChanged",
};

Datamine.Search.Events = EVENTS;
Datamine.Search.State = SEARCH_STATE;

---Private initializer for the search task 'class'
---@param query string
---@param source table
---@param dataKey? string
function DatamineSearchTask:Init(query, source, dataKey)
    self.Callbacks = Callbacks.NewAnonymousRegistry(EVENTS);
    self.State = SEARCH_STATE.PENDING;
    self.Ticker = nil;
    self.Source = source;
    self.DataKey = dataKey;
    self.Query = GenerateSearchableString(query);

    self.CallbackOwners = {};

    self.Found = 0;
    self.Searched = 0;
    self.Total = #source;

    -- As old uncle Meorawr used to tell me:
    -- "On small data sets do only 5% of the set per tick to avoid UI flicker."
    self.Step = math.min(500, math.ceil(self.Total / 20));

    self.Results = {};
end

function DatamineSearchTask:Start()
    assert(self.State == SEARCH_STATE.PENDING, "cannot start an already started search task");

    self.Ticker = C_Timer.NewTicker(0, function() self:Update(); end);
    self:SetState(SEARCH_STATE.RUNNING);
end

function DatamineSearchTask:Restart()
    if self.State ~= SEARCH_STATE.RUNNNG then
        return;
    end

    self.Ticker:Cancel();
    self.Ticker = nil;

    self.Found = 0;
    self.Searched = 0;
    self.Total = #self.Source;
    self.Results = {};

    self:SetState(SEARCH_STATE.PENDING);
    self:Start();
end

function DatamineSearchTask:Finish()
    if self.State == SEARCH_STATE.FINISHED then
        return;
    end

    self.Ticker:Cancel();
    self.Ticker = nil;
    self:SetState(SEARCH_STATE.FINISHED);
end

function DatamineSearchTask:GetState()
    return self.State;
end

function DatamineSearchTask:SetState(newState)
    self.State = newState;
    self.Callbacks:TriggerEvent(EVENTS.STATE_CHANGED, self.State);
end

function DatamineSearchTask:GetQuery()
    return self.Query;
end

function DatamineSearchTask:SetQuery(query)
    query = GenerateSearchableString(query);
    if self:GetQuery() ~= query then
        self.Query = query;

        if self:GetState() == SEARCH_STATE.RUNNING then
            self:Restart();
        else
            self:Start();
        end

        self.Callbacks:TriggerEvent(EVENTS.QUERY_CHANGED, self.Query);
    end
end

function DatamineSearchTask:HasQuery()
    return self.Query and self.Query ~= "";
end

function DatamineSearchTask:GetResults()
    return self.Results;
end

function DatamineSearchTask:GetProgress()
    return {
        Found = self.Found,
        Searched = self.Searched,
        Total = self.Total
    };
end

function DatamineSearchTask:Update()
    local query = self.Query;
    local source = self.Source;
    local found = self.Found;
    local results = self.Results;

    local i = self.Searched + 1;
    local j = math.min(self.Searched + self.Step, self.Total);

    for objIndex = i, j do
        local element = source[objIndex];
        local offset = 1;
        local plain = true;

        if type(element) == "table" then
            element = element[self.DataKey];
        end

        element = GenerateSearchableString(element);

        if element and string.find(element, query, offset, plain) then
            found = found + 1;
            results[found] = objIndex;
        end
    end

    if i == 1 or self.Found ~= found then
        self.Found = found;
        self.Callbacks:TriggerEvent(EVENTS.RESULTS_CHANGED, self.Results);
    end

    self.Searched = j;
    self.Callbacks:TriggerEvent(EVENTS.PROGRESS_CHANGED, self:GetProgress());

    if self.Searched >= self.Total then
        self:Finish();
    end
end

function DatamineSearchTask:RegisterCallback(event, callback, owner)
    local _owner = self.Callbacks:RegisterCallback(event, callback, owner or self);
    tInsertUnique(self.CallbackOwners, _owner);
    return _owner;
end

function DatamineSearchTask:UnregisterAllCallbacks()
    for _, owner in pairs(self.CallbackOwners) do
        for _, event in pairs(EVENTS) do
            self.Callbacks:UnregisterCallback(event, owner);
        end
    end
end

------------

local DatamineSearchableDataProviderMixin = CreateFromMixins(CallbackRegistryMixin);

function DatamineSearchableDataProviderMixin:Init(source)
    self.Source = source;
    self.Results = nil;

    self:GenerateCallbackEvents({ DataProviderMixin.Event.OnSizeChanged, DataProviderMixin.Event.OnSort });
    self:OnLoad();
end

function DatamineSearchableDataProviderMixin:OnResultsChanged(results)
    self.Results = results;
    self:TriggerEvent("OnSizeChanged");
end

function DatamineSearchableDataProviderMixin:ShouldUseResults()
    return self.Results ~= nil;
end

function DatamineSearchableDataProviderMixin:Enumerate(i, j)
    local size = self:GetSize();

    i = i and (i - 1) or 0;
	j = j or size;

	local function Next(_, k)
		k = k + 1;

		if k <= j then
			return k, self:Find(k);
		end
	end

	return Next, nil, i;
end

function DatamineSearchableDataProviderMixin:Find(index)
    local i = self:ShouldUseResults() and self.Results[index] or index;
    return self.Source[i];
end

function DatamineSearchableDataProviderMixin:GetSize()
    return self:ShouldUseResults() and #self.Results or #self.Source;
end


------------

---Creates and initializes a search task
---@param query string
---@param source table
---@param dataKey? string
---@return DatamineSearchTask task
function Datamine.Search.CreateSearchTask(query, source, dataKey)
    local task = CreateAndInitFromMixin(DatamineSearchTask, query, source, dataKey);
    return task;
end

function Datamine.Search.CreateSearchableDataProvider(source)
    local provider = CreateAndInitFromMixin(DatamineSearchableDataProviderMixin, source);
	return provider;
end