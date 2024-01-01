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

    self.Text:SetTextScale(0.85);
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

    self.MinWidth = 150;
    self.MaxWidth = 300;
    self.MinHeight = 200;
    self.MaxHeight = 500;
    self.MaxEntries = 20;

    self.DataProvider:RegisterCallback("OnInsert", self.UpdateSize, self);
    self.DataProvider:RegisterCallback("OnRemove", self.UpdateSize, self);

    self:UpdateSize();
end

function DatamineContextMenuMixin:OnShow()
    self.HasEntered = false;
end

function DatamineContextMenuMixin:OnHide()
    self:Clear();
end

function DatamineContextMenuMixin:CheckShouldClose()
    if not self:IsMouseOver() then
        self:Hide();
    end
end

function DatamineContextMenuMixin:Clear()
    self.ScrollView:Flush();
    self.DataProvider:Flush();
    self.ScrollView:SetDataProvider(self.DataProvider);
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

function Datamine.Unified.ShowContextMenu(elements, frame, frameAnchor, menuAnchor)
    local menu = Datamine.Unified.GetContextMenu();

    if menu:IsShown() then
        menu:Hide();
        return;
    end

    for _, element in pairs(elements) do
        menu:AddMenuEntry(element);
    end

    frameAnchor = frameAnchor or "BOTTOMLEFT";
    menuAnchor = menuAnchor or "TOPLEFT";

    menu:SetPoint(menuAnchor, frame, frameAnchor);
    menu:Show();
end

function Datamine.Unified.HideContextMenu()
    local menu = Datamine.Unified.GetContextMenu(true);
    if menu and menu.Hide then
        menu:Hide();
    end
end