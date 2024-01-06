NineSliceUtil.AddLayout("DatamineCorruptedBorder", {
    TopLeftCorner =	{
        atlas = "Tooltip-Corrupted-NineSlice-CornerTopLeft",
    },
    TopRightCorner = {
        atlas = "Tooltip-Corrupted-NineSlice-CornerTopRight",
    },
    BottomLeftCorner = {
        atlas = "Tooltip-Corrupted-NineSlice-CornerBottomLeft",
    },
    BottomRightCorner =	{
        atlas = "Tooltip-Corrupted-NineSlice-CornerBottomRight",
    },
    TopEdge = {
        atlas = "_Tooltip-Corrupted-NineSlice-EdgeTop",
    },
    BottomEdge = {
        atlas = "_Tooltip-Corrupted-NineSlice-EdgeBottom",
    },
    LeftEdge = {
        atlas = "!Tooltip-Corrupted-NineSlice-EdgeLeft",
    },
    RightEdge = {
        atlas = "!Tooltip-Corrupted-NineSlice-EdgeRight",
    },
});

local bCornerOffset = 4;
local bCenterOffset = 8;
NineSliceUtil.AddLayout("DatamineBlueHighlight", {
    mirrorLayout = true,
    TopLeftCorner =	{
        atlas = "editmode-actionbar-highlight-nineslice-corner",
        x = -bCornerOffset,
        y = bCornerOffset,
    },
    TopRightCorner = {
        atlas = "editmode-actionbar-highlight-nineslice-corner",
        x = bCornerOffset,
        y = bCornerOffset,
    },
    BottomLeftCorner = {
        atlas = "editmode-actionbar-highlight-nineslice-corner",
        x = -bCornerOffset,
        y = -bCornerOffset,
    },
    BottomRightCorner = {
        atlas = "editmode-actionbar-highlight-nineslice-corner",
        x = bCornerOffset,
        y = -bCornerOffset,
    },
    TopEdge = {
        atlas = "_editmode-actionbar-highlight-nineslice-edgetop",
    },
    BottomEdge = {
        atlas = "_editmode-actionbar-highlight-nineslice-edgebottom",
        mirrorLayout = false,
    },
    LeftEdge = {
        atlas = "!editmode-actionbar-highlight-nineslice-edgeleft",
        mirrorLayout = false,
    },
    RightEdge = {
        atlas = "!editmode-actionbar-highlight-nineslice-edgeright",
        mirrorLayout = false,
    },
    Center = {
        atlas = "editmode-actionbar-highlight-nineslice-center",
        x = -bCenterOffset,
        y = bCenterOffset,
        x1 = bCenterOffset,
        y1 = -bCenterOffset
    },
});