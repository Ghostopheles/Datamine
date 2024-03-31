DataminePopupBoxMixin = {};

function DataminePopupBoxMixin:OnHide()
    self:SetTitle("");
    self:SetText("");
    self:SetCallback(nil);
end

function DataminePopupBoxMixin:ShowPopup(title, text, callback)
    self:SetTitle(title);
    self:SetText(text);
    self:SetCallback(callback);
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