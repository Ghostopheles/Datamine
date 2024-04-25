local L = Datamine.Strings;
local Registry = Datamine.EventRegistry;
local Events = Datamine.Events;

------------

DatamineMapViewerMixin = {};

function DatamineMapViewerMixin:OnLoad()
end

-- Need to throw this in here to avoid erroring
function DatamineMapViewerMixin:OnCanvasSizeChanged()
end