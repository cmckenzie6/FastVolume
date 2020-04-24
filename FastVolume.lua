FastVolume = {}
FastVolume.name = "FastVolume"
 
function FastVolume:Initialize()
	self.savedVariables = ZO_SavedVars:NewAccountWide("FastVolumeSavedVariables", 1, nil, FastVolume.Default)
    local visibility = self.savedVariables.visibility
    self:RestoreState()
	
	-- Register slash command
	SLASH_COMMANDS["/fv"] = SetMasterVolume
	
	--------------
	-- BINDINGS --
	--------------
	
	-- Mute tooltip
	FastVolumePanelToggle.tooltipText = "Double-click to toggle mute."
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
  FastVolumeAnchor:ClearAnchors()
  FastVolumeAnchor:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

--[[
Set volume to the selected value. This function can be called programmatically or via slash command.

Valid slash commands:
	/fv             Display help
	/fv help        Display help
	/fv [0-100]     Set volume to value
	/fv mute        Toggle mute
	/fv unmute      Alias of mute
	/fv mute on     Alias of mute
	/fv mute off    Alias of mute
	/fv lock        Lock window position
	/fv unlock      Unlock window position
]]--

function SetMasterVolume(--[[optional]]option)
	-- source: https://wiki.esoui.com/How_to_add_a_slash_command
    local options = {}
    local searchResult = { string.match(option,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end

  -- Handle missing parameters
  if (options[1] == nil or options[1] == '' or options[1] == 'help' or #options == 0) then
    d(zo_strformat("|cFF0000FastVolume|r Help:\n|c00FF00/fv help|r  Display help\n|c00FF00/fv [0-100]|r  Set volume to value\n|c00FF00/fv mute|r  Toggle mute\n|c00FF00/fv lock|r  Lock window position\n|c00FF00/fv unlock|r  Unlock window position",options[1]))
  -- Handle mute parameters
  elseif (options[1] == "mute" or options[1] == "unmute" or (options[1] == "mute" and (options[2] == "on" or options[2] == "off"))) then
    FastVolume:ToggleMute()
  -- Handle unlock parameter
  elseif (options[1] == "unlock") then
    FastVolume:Unlock()
  -- Handle lock parameter
  elseif (options[1] == "lock") then
    FastVolume:Lock()
  -- Handle non-numeric parameters
  elseif (tonumber(options[1]) == nil) then
    d(zo_strformat("|cFF0000FastVolume|r |c00FF00Error:|r <<1>> is not a valid volume level. Type /fv [0-100] to set the volume to a given level.",options[1]))
  else
    -- Set the volume to the given value
	valueAsNumber = tonumber(options[1])
	if (valueAsNumber >= 0 and valueAsNumber <= 100) then
	  d(zo_strformat("|cFF0000FastVolume|r set master volume to <<1>>.",valueAsNumber))
	  SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, valueAsNumber)
	else
	  -- Handle numbers outside of the valid range
	  d(zo_strformat("|cFF0000FastVolume|r |c00FF00Error:|r <<1>> is not a valid volume level. The volume level must be an integer between 0 and 100.",options[1]))
	end
  end
end

-- Toggle muted state
function FastVolume:ToggleMute()
  if(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED) == "1") then
    FastVolumePanelToggle:SetTexture("FastVolume/media/muted.dds")
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, "0")
	d("|cFF0000FastVolume|r mute ON.")
  else
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, "1")
	FastVolumePanelToggle:SetTexture("/esoui/art/voip/gamepad/gp_voip_listening.dds")
	d("|cFF0000FastVolume|r mute OFF.")
  end
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