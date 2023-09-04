local moduleName = "ModelView";

local Print = function(...) Datamine.Print(moduleName, ...) end;
local Dump = function(title, ...) Datamine.Dump(moduleName, title, ...) end;

Datamine.ModelView = {};

local function SetupPlayerForModelScene(modelScene, overrideActorName, itemModifiedAppearanceIDs, sheatheWeapons, autoDress, hideWeapons, useNativeForm)
	if not modelScene then
		return;
	end

	local actor = modelScene:GetPlayerActor(overrideActorName);
	if actor then
		sheatheWeapons = (sheatheWeapons == nil) or sheatheWeapons;
		hideWeapons = (hideWeapons == nil) or hideWeapons;
		useNativeForm = (useNativeForm == nil) or useNativeForm;
		actor:SetModelByUnit("player", sheatheWeapons, autoDress, hideWeapons, useNativeForm);

		if itemModifiedAppearanceIDs then
			for _, itemModifiedAppearanceID in ipairs(itemModifiedAppearanceIDs) do
				actor:TryOn(itemModifiedAppearanceID);
			end
		end
		actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
	end
end

function Datamine.ModelView:IsModelViewShown()
	return DatamineDressUpFrame:IsShown();
end

local DRESS_UP_FRAME_MODEL_SCENE_ID = 596;
function Datamine.ModelView:Show(itemModifiedAppearanceIDs, forcePlayerRefresh)
    local f = DatamineDressUpFrame;

    if ( forcePlayerRefresh or (not f:IsShown() or f:GetMode() ~= "player") ) then
		f:SetMode("player");

		f:Show();
		f.ModelScene:ClearScene();
		f.ModelScene:SetViewInsets(0, 0, 0, 0);
		f.ModelScene:ReleaseAllActors();
		f.ModelScene:TransitionToModelSceneID(DRESS_UP_FRAME_MODEL_SCENE_ID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);

		local overrideActorName = nil;
		local sheatheWeapons = true;
		local autoDress = true;
		local hideWeapons = false;
		local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
		local useNativeForm = not inAlternateForm;
		SetupPlayerForModelScene(f.ModelScene, overrideActorName, itemModifiedAppearanceIDs, sheatheWeapons, autoDress, hideWeapons, useNativeForm);
	end

	if DevTool then
		DevTool:AddData(f.ModelScene:GetPlayerActor(), "PlayerActor");
	end
end

---@param itemModifiedAppearanceIDs table
---@return boolean
function Datamine.ModelView:TryOnByItemModifiedAppearanceID(itemModifiedAppearanceIDs)
	if not self:IsModelViewShown() then
		self:Show();
	end

    local actor = DatamineDressUpFrame:GetActor();
    if not actor then
		Print("Actor not found.");
        return false;
    end

	for _, itemModifiedAppearanceID in ipairs(itemModifiedAppearanceIDs) do
		local result = actor:TryOn(itemModifiedAppearanceID);
		if result ~= Enum.ItemTryOnReason.Success then
			Print("ItemModifiedAppearance " .. itemModifiedAppearanceID .. " cannot be equipped.");
		end
	end
	return true;
end

-- just ItemAppearanceID NOT ItemModifiedAppearanceID
function Datamine.ModelView:TryOnByAppearanceID(appearanceID)
	if not self:IsModelViewShown() then
		self:Show();
	end

	local actor = DatamineDressUpFrame:GetActor();
    if not actor then
		Print("Actor not found.");
        return false;
    end

	local GetEnumValueName = EnumUtil.GenerateNameTranslation(Enum.ItemTryOnReason);

	local _, canCollect = C_TransmogCollection.AccountCanCollectSource(appearanceID);
	if not canCollect then
		Print("ItemModifiedAppearance " .. appearanceID .. " cannot be collected by this account.");
	end

	local transmogInfo = ItemUtil.CreateItemTransmogInfo(appearanceID);
    local appearanceInfo = C_TransmogCollection.GetSourceInfo(appearanceID);
    local _, _, _, itemEquipLoc, _ = GetItemInfoInstant(appearanceInfo.itemID);

    local _, _, _, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(appearanceInfo.categoryID);
    local weaponSlotID = (canMainHand and canOffHand) and itemEquipLoc or nil;

    local ignoreChildItems = true;
    if itemEquipLoc == INVSLOT_MAINHAND then
        local isLegionArtifact = TransmogUtil.IsCategoryLegionArtifact(appearanceInfo.categoryID);
        transmogInfo:ConfigureSecondaryForMainHand(isLegionArtifact);
		-- we only want child items if the appearance is from Legion Artifact category
		if isLegionArtifact then
			ignoreChildItems = false;
		end
    end

    local result = actor:SetItemTransmogInfo(transmogInfo, weaponSlotID, ignoreChildItems);
    Print("Try on result: " .. GetEnumValueName(result));
    return true;
end

function Datamine.ModelView:TryOnTransmogSet(transmogSetID)
    local itemModifiedAppearanceIDs = C_TransmogSets.GetAllSourceIDs(transmogSetID);

	self:TryOnByItemModifiedAppearanceID(itemModifiedAppearanceIDs);
    return true;
end

function Datamine.ModelView:TryOnByItemID(itemID)
    local appearanceID, itemModifiedAppearanceID = C_TransmogCollection.GetItemInfo(itemID);

	self:TryOnByItemModifiedAppearanceID({itemModifiedAppearanceID});
    return true;
end

do
	local helpString = "Show the Datamine dressing room.";

	Datamine.Slash:RegisterCommand("dressup", function(...) Datamine.ModelView:Show(nil, true); end, helpString, moduleName);
end

do
	local helpMessage = "Try on an item by item ID";
	local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<itemID>", helpMessage);

	Datamine.Slash:RegisterCommand("tryonitem", function(itemID) Datamine.ModelView:TryOnByItemID(itemID) end, helpString, moduleName);
end

do
	local helpMessage = "View an ItemModifiedAppearance in the Datamine dressing room.";
	local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<itemModifiedAppearanceID>", helpMessage);

	Datamine.Slash:RegisterCommand("appearance", function(...) Datamine.ModelView:TryOnByItemModifiedAppearanceID({...}) end, helpString, moduleName);
end

--do
--	local helpMessage = "View an ItemAppearance in the Datamine dressing room.";
--	local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<itemAppearanceID>", helpMessage);
--
--	Datamine.Slash:RegisterCommand("appearance", function(appearanceID) Datamine.ModelView:TryOnByAppearanceID(appearanceID) end, helpString, moduleName);
--end

do
	local helpMessage = "View a TransmogSet in the Datamine dressing room.";
	local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<transmogSetID>", helpMessage);

	Datamine.Slash:RegisterCommand("transmogset", function(transmogSetID) Datamine.ModelView:TryOnTransmogSet(transmogSetID) end, helpString, moduleName);
end