local L = Datamine.Strings;

Datamine.Popup = {};

Datamine.Popup.PopupType = {
    SINGLE = 1,
    BINARY = 2,
};

local POPUP_TYPE = Datamine.Popup.PopupType;

DataminePopupBoxMixin = {};

function DataminePopupBoxMixin:OnLoad()
    self.TextSet = false;
end

function DataminePopupBoxMixin:OnShow()
    self:LoadButtonText();
end

function DataminePopupBoxMixin:OnHide()
    self:SetTitle("");
    self:SetText("");
    self:SetCallback(nil);
end

function DataminePopupBoxMixin:LoadButtonText()
    if not self.TextSet then
        local container = self.ButtonContainer;
        container.Buttons[1]:SetText(L.GENERIC_YES);
        container.Buttons[2]:SetText(L.GENERIC_NO);
        container.OkButton:SetText(L.GENERIC_OKAY);

        self.TextSet = true;
    end
end

function DataminePopupBoxMixin:UpdateButtonVisibilityForPopupType(popupType)
    popupType = popupType or POPUP_TYPE.SINGLE;

    local container = self.ButtonContainer;
    if popupType == POPUP_TYPE.SINGLE then
        for _, button in ipairs(container.Buttons) do
            button:Hide();
        end
        container.OkButton:Show();
    elseif popupType == POPUP_TYPE.BINARY then
        for _, button in ipairs(container.Buttons) do
            button:Show();
        end
        container.OkButton:Hide();
    end
end

function DataminePopupBoxMixin:ShowPopup(title, text, callback, popupType)
    self:SetTitle(title);
    self:SetText(text);
    self:SetCallback(callback);
    self:UpdateButtonVisibilityForPopupType(popupType);

    self:Show();
end

function DataminePopupBoxMixin:SetTitle(text)
    self.TitleBar.Text:SetText(text);
end

function DataminePopupBoxMixin:SetText(text)
    self.TextBox.Text:SetText(text);
end

function DataminePopupBoxMixin:SetCallback(callback)
    self.Callback = callback;
end

function DataminePopupBoxMixin:OnButtonClicked(choice)
    if type(self.Callback) == "function" then
        self.Callback(choice);
    end

    self:Hide();
end

------------

function Datamine.Popup.ShowPopup(...)
    DataminePopupBox:ShowPopup(...);
end