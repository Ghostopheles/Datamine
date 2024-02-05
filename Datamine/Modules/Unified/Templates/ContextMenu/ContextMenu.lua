---@class ContextMenuEntryData
---@field Text string
---@field Callback function
---@field SubmenuElements? table<ContextMenuEntryData>

DatamineContextMenuEntryMixin = {};

---@param data ContextMenuEntryData
function DatamineContextMenuEntryMixin:Init(data)
    self.Data = data;
    self.Callback = data.Callback;
    self:SetText(data.Text);

    self.SubmenuElements = data.SubmenuElements;

    if self.SubmenuElements then
        self.ExpandChevron:Show();
    else
        self.ExpandChevron:Hide();
    end
end

function DatamineContextMenuEntryMixin:OnClick()
    if self.Callback then
        self.Callback(self);
    end

    if not self.SubmenuElements then
        Datamine.Unified.HideContextMenu();
    end
end

function DatamineContextMenuEntryMixin:OnEnter()
end

function DatamineContextMenuEntryMixin:OnLeave()
end

function DatamineContextMenuEntryMixin:SetText(text)
    self.Text:SetText(text);
end

-------------

DatamineContextMenuMixin = {};

function DatamineContextMenuMixin:OnLoad()
    self.MinWidth = 150;
    self.MaxWidth = 300;
    self.MinHeight = 200;
    self.MaxHeight = 500;
    self.MaxEntries = 20;

    self.DataProvider = CreateDataProvider();

    self.ScrollView = CreateScrollBoxListLinearView();
    self.ScrollView:SetDataProvider(self.DataProvider);
    self.ScrollView:SetElementExtent(15);

    local function Initializer(button, data)
        button:Init(data);
    end

    self.ScrollView:SetElementInitializer("DatamineContextMenuEntryTemplate", Initializer);
    self.ScrollBar:SetHideIfUnscrollable(true);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    self.DataProvider:RegisterCallback("OnSizeChanged", self.OnDataProviderSizeChanged, self);

    self:UpdateSize();
end

function DatamineContextMenuMixin:OnShow()
end

function DatamineContextMenuMixin:OnHide()
    self:Clear();
end

function DatamineContextMenuMixin:OnDataProviderSizeChanged()
    self:UpdateSize();
end

function DatamineContextMenuMixin:Clear()
    self:SetOwner(nil);
    self:ClearAllPoints();

    self.ScrollView:Flush();
    self.DataProvider = CreateDataProvider();
    self.ScrollView:SetDataProvider(self.DataProvider);
end

function DatamineContextMenuMixin:SetOwner(owner)
    self.Owner = owner;
end

function DatamineContextMenuMixin:GetOwner()
    return self.Owner;
end

function DatamineContextMenuMixin:UpdateSize()
    -- height
    local elementCount = self.DataProvider:GetSize();
    local elementHeight = self.ScrollView:GetElementExtent();
    local spacing = 4;
    local height = (elementHeight * elementCount) + spacing;
    if height > self.MaxHeight then
        height = self.MaxHeight;
    end
    self:SetHeight(height);
    self:SetWidth(self.MinWidth);
end

---@param data ContextMenuEntryData
function DatamineContextMenuMixin:AddMenuEntry(data)
    if self.DataProvider:GetSize() < 20 then
        self.DataProvider:Insert(data);
    end
end

-------------

-- context menu accessor
function Datamine.Unified.GetContextMenu(doNotCreate)
    local menu = Datamine.Unified.ContextMenu;
    if not menu and not doNotCreate then
        menu = CreateFrame("Frame", "DatamineContextMenu", DatamineUnifiedFrame, "DatamineContextMenuTemplate");
        Datamine.Unified.ContextMenu = menu;
    end

    return menu;
end

---@param elements table
---@param anchorTargetFrame frame
---@param parentAnchorPoint? AnchorPoint
---@param menuAnchorPoint? AnchorPoint
---@param owner? frame
function Datamine.Unified.ShowContextMenu(elements, anchorTargetFrame, parentAnchorPoint, menuAnchorPoint, owner)
    local menu = Datamine.Unified.GetContextMenu();

    owner = owner or anchorTargetFrame;
    parentAnchorPoint = parentAnchorPoint or "BOTTOMLEFT";
    menuAnchorPoint = menuAnchorPoint or "TOPLEFT";

    if menu:IsShown() and menu:GetOwner() == owner then
        menu:Hide();
        return;
    end

    for _, element in pairs(elements) do
        menu:AddMenuEntry(element);
    end

    menu:SetOwner(owner);
    menu:SetPoint(menuAnchorPoint, anchorTargetFrame, parentAnchorPoint);
    menu:Show();
end

function Datamine.Unified.HideContextMenu()
    local menu = Datamine.Unified.GetContextMenu(true);
    if menu and menu.Hide then
        menu:Hide();
    end
end