---@class ButtonData
---@field Template string
---@field Text? string
---@field IsTopLevel? boolean
---@field ShowChevron? boolean
---@field CanExpand? boolean
---@field RequestedExtent? number
---@field ControlID? string
---@field DataFetch? function
---@field Callback? function
---@field DefaultsFunc? function
---@field OverlordFrame? frame
---@field SortFunc? function
---@field SortChildren? boolean
---@field BackgroundColor? ColorMixin

DatamineTabTreeViewCategoryHeaderMixin = {};

function DatamineTabTreeViewCategoryHeaderMixin:Init(node)
    ---@type ButtonData
    local data = node:GetData();

    self:SetText(data.Text);

    if data.Callback then
        self.Callback = data.Callback;
    else
        self.Callback = nil;
    end

    self.CanExpand = data.CanExpand;

    self.CollapsedChevronAtlas = "uitools-icon-chevron-right";
    self.UncollapsedChevronAtlas = "uitools-icon-chevron-down";
    self:UpdateChevron();

    self.Background:SetColorTexture(data.BackgroundColor:GetRGB());

    self:Show();
end

function DatamineTabTreeViewCategoryHeaderMixin:OnUpdate()
    if not self:IsShown() then
        return;
    end
    self:UpdateChevron();
end

function DatamineTabTreeViewCategoryHeaderMixin:OnClick()
    if self.CanExpand then
        local node = self:GetElementData();
        node:ToggleCollapsed();
        self:UpdateChevron();
    end

    if self.Callback then
        self:Callback();
    end
end

function DatamineTabTreeViewCategoryHeaderMixin:UpdateChevron()
    if not self.CanExpand then
        self.Chevron:Hide();
        self.Text:SetPoint("LEFT");
    else
        self.Chevron:Show();
        self.Text:SetPoint("LEFT", self.Chevron, "RIGHT");
    end


    if self:GetElementData():IsCollapsed() then
        self.Chevron:SetCustomAtlas(self.CollapsedChevronAtlas);
    else
        self.Chevron:SetCustomAtlas(self.UncollapsedChevronAtlas);
    end
end

function DatamineTabTreeViewCategoryHeaderMixin:SetText(text)
    self.Text:SetText(text);
end

-------------

DatamineTabTreeViewMixin = {};

function DatamineTabTreeViewMixin:OnLoad_Base()
    self.DataProvider = CreateTreeDataProvider();

    self.ScrollView = CreateScrollBoxListTreeListView();
    self.ScrollView:SetDataProvider(self.DataProvider);
    self.ScrollView:SetPanExtent(20);

    local TOP_LEVEL_EXTENT = 20;
    local DEFAULT_EXTENT = 20;
    self.ScrollView:SetElementExtentCalculator(function(_, elementData)
        local extent;
        local data = elementData:GetData();
        if data.RequestedExtent then
            extent = data.RequestedExtent;
        elseif data.IsTopLevel then
            extent = TOP_LEVEL_EXTENT;
        else
            extent = DEFAULT_EXTENT;
        end

        return extent;
    end);

    local function Initializer(frame, node)
        frame:Init(node);
    end

    self.ScrollView:SetElementFactory(function(factory, node)
		local data = node:GetData();
		local template = data.Template;
		factory(template, Initializer);
	end);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    local anchorsWithScrollBar = {
        CreateAnchor("TOPLEFT", 4, -4);
        CreateAnchor("BOTTOMRIGHT", self.ScrollBar, -13, 4),
    };

    local anchorsWithoutScrollBar = {
        CreateAnchor("TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", -4, 4);
    };

    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, anchorsWithScrollBar, anchorsWithoutScrollBar);

    self.DataProvider:CollapseAll();
end

function DatamineTabTreeViewMixin:AddTopLevelItem(data)
    if not data.Template then
        data.Template = "DatamineTabTreeViewCategoryHeaderTemplate";
    end

    if data.IsTopLevel == nil then
        data.IsTopLevel = true;
    end

    if not data.BackgroundColor then
        data.BackgroundColor = DatamineLightGray;
    end

    local node = self.DataProvider:Insert(data);
    if data.SortFunc then
        node:SetSortComparator(data.SortFunc, data.SortChildren);
    end

    return node;
end

function DatamineTabTreeViewMixin:AddTable(tbl)
    self.DataProvider:InsertTable(tbl);
end

function DatamineTabTreeViewMixin:Reset()
    self.ScrollView:Flush();
    self.DataProvider = CreateTreeDataProvider();
    self.ScrollView:SetDataProvider(self.DataProvider);
end

-------------

DatamineTabTreeViewChildKeyValueMixin = {}

function DatamineTabTreeViewChildKeyValueMixin:Init(node)
    local data = node:GetData();

    if data.KeyValue then
        self.Key:SetText(data.KeyValue.Key);
        self.Value:SetText(data.KeyValue.Value);

        self.Separator:SetTextColor(DatamineLightGray.r, DatamineLightGray.g, DatamineLightGray.b, DatamineLightGray.a);
        self.Separator:SetTextScale(1.5);
    else
        node:Remove();
    end
end