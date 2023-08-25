Datamine.ModelView = {};

local DEBUG_ID = 191878;

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
		local sheatheWeapons = false;
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

function Datamine.ModelView:TryOn(...)
    self:Show();

    local playerActor = DatamineDressUpFrame.ModelScene:GetPlayerActor();
    if not playerActor then
        return false;
    end

    local result = playerActor:TryOn(...);
    if result ~= Enum.ItemTryOnReason.Success then
		UIErrorsFrame:AddExternalErrorMessage(ERR_NOT_EQUIPPABLE);
	end
	return true;
end


local helpMessage = "Try on an item in the dressing room.";
local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<itemModifiedAppearanceID>", helpMessage);

Datamine.Slash:RegisterCommand("mog", function(itemModifiedAppearanceID) Datamine.ModelView:TryOn(tonumber(itemModifiedAppearanceID)) end, helpString);