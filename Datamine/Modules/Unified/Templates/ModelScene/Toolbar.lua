DatamineModelSceneToolbarButtonMixin = {};

function DatamineModelSceneToolbarButtonMixin:OnMouseUp(button)
    if self.Callback then
        self:Callback(button);
    end
end

function DatamineModelSceneToolbarButtonMixin:OnEnter()
    if self.TooltipText then
        GameTooltip:SetOwner(self, "ANCHOR_TOP");
        GameTooltip:SetText(self.TooltipText, 1, 1, 1, 1);
        GameTooltip:Show();
    end
end

function DatamineModelSceneToolbarButtonMixin:OnLeave()
    if GameTooltip:IsOwned(self) then
        GameTooltip:Hide();
    end
end

function DatamineModelSceneToolbarButtonMixin:SetCallback(callback)
    self.Callback = callback;
end

function DatamineModelSceneToolbarButtonMixin:SetIcon(iconTexture, scale)
    local isAtlas = C_Texture.GetAtlasID(iconTexture) ~= 0;
    if isAtlas then
        self.Icon:SetAtlas(iconTexture);
    else
        self.Icon:SetTexture(iconTexture);
    end
end

function DatamineModelSceneToolbarButtonMixin:SetTooltipText(tooltipText)
    self.TooltipText = tooltipText;
end

------------

DatamineModelSceneToolbarMixin = {};

function DatamineModelSceneToolbarMixin:OnLoad()
    self.Buttons = {};
    self.ButtonTemplate = self.ButtonTemplate or "DatamineModelSceneToolbarButtonTemplate";
    self.ButtonPool = CreateFramePool("Button", self, self.ButtonTemplate);

    local stride = 5;
    local paddingX, paddingY = 0, 0;
    local horizontalSpacing, verticalSpacing = nil, nil;
    self.Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.BottomToTop, stride, paddingX, paddingY, horizontalSpacing, verticalSpacing);
    self.InitialAnchor = AnchorUtil.CreateAnchor("TOPRIGHT", self, "TOPRIGHT", 0, 0);

    self:SetWidth(35);
end

function DatamineModelSceneToolbarMixin:AddButton(icon, callback, tooltipText)
    local button = self.ButtonPool:Acquire();
    button:SetIcon(icon);
    button:SetCallback(callback);
    button:SetTooltipText(tooltipText);

    tinsert(self.Buttons, button);
    self:UpdateLayout();

    button:Show();
    return button;
end

function DatamineModelSceneToolbarMixin:UpdateLayout()
    local buttons = self.Buttons;
    local numButtons = #buttons;
    if numButtons == 0 then
        return;
    end

    local height = buttons[1]:GetHeight() * numButtons;
    self:SetHeight(height);

    AnchorUtil.GridLayout(buttons, self.InitialAnchor, self.Layout);
end