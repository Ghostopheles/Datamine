---@class ButtonData
---@field Template string
---@field Text? string
---@field IsTopLevel? boolean
---@field ShowChevron? boolean
---@field RequestedExtent? number

DatamineTabTreeViewCategoryHeaderMixin = {};

function DatamineTabTreeViewCategoryHeaderMixin:Init(node)
    ---@type ButtonData
    local data = node:GetData();

    self:SetText(data.Text);
    self:SetScript("OnClick", function() node:ToggleCollapsed(); end);

    if data.ShowChevron then
        self:SetupChevron();
    end

    self:Show();
end

function DatamineTabTreeViewCategoryHeaderMixin:SetupChevron()
    local fileName = Datamine.Unified.AtlasInfo:GetAtlasFileName("UITools");
    local atlas = Datamine.Unified.AtlasInfo:GetAtlasInfo("UITools", "uitools-icon-chevron-right");
    self.Chevron:SetTexture(fileName);
    self.Chevron:SetTexCoord(atlas.left, atlas.right, atlas.top, atlas.bottom);
    self.Chevron:Show();
end

function DatamineTabTreeViewCategoryHeaderMixin:SetText(text)
    self.Text:SetText(text);
end

-------------

DatamineTabTreeViewMixin = {};

function DatamineTabTreeViewMixin:OnLoad()
    self.DataProvider = CreateTreeDataProvider();

    --[[
    for i = 1, 10 do
        -- The data supplied to the insert calls is arbitrary; it can be accessed
        -- from the 'node:GetData()' call later in the element initializer.
        local l1Data = {
            Text = format("Node %d", i),
            Template = "DatamineTabTreeViewCategoryHeaderTemplate",
            IsTopLevel = true,
            ShowChevron = false,
        };
        local level1 = self.DataProvider:Insert(l1Data);
        level1:Insert({
            Text = "TEXT",
            Template = "DatamineTreeModelControlsLabelledEditBoxRowTemplate",
            RequestedExtent = 20,
        });
        for j = 1, fastrandom(3, 6) do
            local l2Data = {
                Text = format("Node %d.%d", i, j),
                Template = "DatamineTabTreeViewSubCategoryTemplate",
            };

            local level2 = level1:Insert(l2Data);
            for k = 1, fastrandom(1, 3) do
                local l3Data = {
                    Text = format("Node %d.%d.%d", i, j, k),
                    Template = "DatamineTabTreeViewSubCategoryTemplate",
                };
                level2:Insert(l3Data)
            end
        end
    end
    ]]--

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

    self.ScrollBox:SetInterpolateScroll(true);
    self.ScrollBar:SetInterpolateScroll(true);
    self.ScrollBar:SetHideIfUnscrollable(true);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    --self.SelectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox);
    --self.SelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, self.OnSelectionChanged, self);

    self.DataProvider:CollapseAll();
end

function DatamineTabTreeViewMixin:AddTopLevelItem(data)
    return self.DataProvider:Insert(data);
end

-------------
