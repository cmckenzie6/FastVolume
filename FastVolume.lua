FastVolume = {}
FastVolume.name = "FastVolume"
 
function FastVolume:Initialize()
	self.savedVariables = ZO_SavedVars:NewAccountWide("FastVolumeSavedVariables", 1, nil, FastVolume.Default)
    local visibility = self.savedVariables.visibility
    self:RestoreState()
	
	-- Initialize tooltip
	FastVolumePanelToggle.tooltipText = "Show/Hide Volume Controls"
	FastVolumePanelToggle:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(self, TOP, self.tooltipText)
    end)
    FastVolumePanelToggle:SetHandler("OnMouseExit", function(self)
       ZO_Tooltips_HideTextTooltip()
    end)
end

-- Save window position
function FastVolume.OnIndicatorMoveStop()
  FastVolume.savedVariables.left = FastVolumePanel:GetLeft()
  FastVolume.savedVariables.top = FastVolumePanel:GetTop()
end

-- Restore saved window position and visibility
function FastVolume:RestoreState()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
  
  FastVolume:FVSetHidden(self.savedVariables.visibility)
   
  FastVolumePanel:ClearAnchors()
  FastVolumePanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

-- Set volume to the selected value
function FastVolume:SetMasterVolume(value)
	d(zo_strformat("|cFF0000FastVolume|r set master volume to <<1>>.",value))
	PlaySound(SOUNDS.DEFAULT_CLICK)
	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, value)
end

-- Set visibility of volume buttons
function FastVolume:FVSetHidden(state)
	FastVolume.savedVariables.visibility = state
	visibility = state
	FastVolumePanelBackdrop:SetHidden(state)
	FastVolumePanelButton0:SetHidden(state)
	FastVolumePanelButton25:SetHidden(state)
	FastVolumePanelButton50:SetHidden(state)
	FastVolumePanelButton75:SetHidden(state)
	FastVolumePanelButton100:SetHidden(state)
end

-- Toggle volume button visibility
function FastVolume:TogglePanel()
	PlaySound(SOUNDS.DEFAULT_CLICK)
	FastVolume:FVSetHidden(not(visibility))
end
 
function FastVolume.OnAddOnLoaded(event, addonName)
  if addonName == FastVolume.name then
    FastVolume:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(FastVolume.name, EVENT_ADD_ON_LOADED, FastVolume.OnAddOnLoaded)