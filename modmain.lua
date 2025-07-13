env._G = GLOBAL._G
GLOBAL.setfenv(1, env)

Assets = {  }
PrefabFiles = {  }

modimport("scripts/LFCconstants")

local old_CreateEntity = _G.CreateEntity
_G.CreateEntity = function(name, ...)
    local ent = old_CreateEntity(name, ...)

    if name == "TheGlobalInstance" then
        _G.global("DSTFollowCamera") -- Because of "strict" global rules set up by strict.lua
        _G.DSTFollowCamera = _G.TheCamera
        _G.global("LFCFreeCamera")
        _G.LFCFreeCamera = require("cameras/LFCfreecamera")()
    end

    return ent
end

local PlayerController = require("components/playercontroller")
local old_DoCameraControl = PlayerController.DoCameraControl
PlayerController.DoCameraControl = function(self, ...)
    if not _G.TheCamera:CanControl() then
        return
    end

    local isenabled, ishudblocking = self:IsEnabled()
    if not isenabled or ishudblocking then
        return
    end

    if _G.TheCamera == _G.LFCFreeCamera then
        local forward = _G.TheInput:IsControlPressed(_G.CONTROL_MOVE_UP)
        local backwards = _G.TheInput:IsControlPressed(_G.CONTROL_MOVE_DOWN)
        local left = _G.TheInput:IsControlPressed(_G.CONTROL_MOVE_LEFT)
        local right = _G.TheInput:IsControlPressed(_G.CONTROL_MOVE_RIGHT)
        local up = _G.TheInput:IsControlPressed(_G.CONTROL_ROTATE_RIGHT)
        local down = _G.TheInput:IsControlPressed(_G.CONTROL_ROTATE_LEFT)

        _G.TheCamera:SetMovingDir(0, 0, 0)

        local move_vec = _G.Vector3(0, 0, 0)
        if forward then
            move_vec.z = move_vec.z + 1
        end

        if backwards then
            move_vec.z = move_vec.z - 1
        end

        if right then
            move_vec.x = move_vec.x + 1
        end

        if left then
            move_vec.x = move_vec.x - 1
        end

        if up then
            move_vec.y = move_vec.y + 1
        end

        if down then
            move_vec.y = move_vec.y - 1
        end

        _G.TheCamera:SetMovingDir(move_vec)
    end

    old_DoCameraControl(self, ...)
end

-- local MYISettingsTab = require("widgets/MYIsettingstab")
-- local OptionsScreen = require("screens/redux/optionsscreen")
-- local old_OptionsScreen_BuildMenu = OptionsScreen._BuildMenu
-- OptionsScreen._BuildMenu = function(self, subscreener, ...)
--     subscreener.sub_screens["MYI"] = self.panel_root:AddChild(MYISettingsTab(self))
--     local menu = old_OptionsScreen_BuildMenu(self, subscreener, ...)

-- 	local myi_button = subscreener:MenuButton(_G.MYI.SETTINGS.NAME, "MYI", _G.MYI.SETTINGS.TOOLTIP, self.tooltip)
--     menu:AddCustomItem(myi_button)
--     local pos = _G.Vector3(0, 0, 0)
--     pos.y = pos.y + menu.offset * (#menu.items - 1)
--     myi_button:SetPosition(pos)
    
--     return menu
-- end

-- local function EnabledOptionsIndex(enabled)
--     return enabled and 2 or 1
-- end

-- if _G.Profile:GetValue(_G.MYI.SETTINGS.OPTIONS.WORLD_Y.OPTIONS_STR) == nil then
--     _G.Profile:SetValue(_G.MYI.SETTINGS.OPTIONS.WORLD_Y.OPTIONS_STR, true) -- true is the default value
-- end

-- local old_OptionsScreen_DoInit = OptionsScreen.DoInit
-- OptionsScreen.DoInit = function(self, ...)
--     self.options[_G.MYI.SETTINGS.OPTIONS.WORLD_Y.OPTIONS_STR] = _G.Profile:GetValue(_G.MYI.SETTINGS.OPTIONS.WORLD_Y.OPTIONS_STR)
--     self.working[_G.MYI.SETTINGS.OPTIONS.WORLD_Y.OPTIONS_STR] = _G.Profile:GetValue(_G.MYI.SETTINGS.OPTIONS.WORLD_Y.OPTIONS_STR)

--     self.options[_G.MYI.SETTINGS.OPTIONS.SHADOWS.OPTIONS_STR] = _G.Profile:GetValue(_G.MYI.SETTINGS.OPTIONS.SHADOWS.OPTIONS_STR)
--     self.working[_G.MYI.SETTINGS.OPTIONS.SHADOWS.OPTIONS_STR] = _G.Profile:GetValue(_G.MYI.SETTINGS.OPTIONS.SHADOWS.OPTIONS_STR)

--     old_OptionsScreen_DoInit(self, ...)
-- end

-- local old_OptionsScreen_Apply = OptionsScreen.Apply
-- OptionsScreen.Apply = function(self, ...)
--     _G.Profile:SetValue(_G.MYI.SETTINGS.OPTIONS.WORLD_Y.OPTIONS_STR, self.working[_G.MYI.SETTINGS.OPTIONS.WORLD_Y.OPTIONS_STR])
--     _G.Profile:SetValue(_G.MYI.SETTINGS.OPTIONS.SHADOWS.OPTIONS_STR, self.working[_G.MYI.SETTINGS.OPTIONS.SHADOWS.OPTIONS_STR])

--     if _G.ThePlayer then -- Player exists == we're changing setting during playtime
--         _G.ThePlayer.mc_items = {  } -- Reset the mc item tracker
--     end

--     old_OptionsScreen_Apply(self, ...)
-- end

-- local old_OptionsScreen_InitializeSpinners = OptionsScreen.InitializeSpinners
-- OptionsScreen.InitializeSpinners = function(self, ...)
--     self.subscreener.sub_screens["MYI"].worldYSpinner:SetSelectedIndex(EnabledOptionsIndex(self.working[_G.MYI.SETTINGS.OPTIONS.WORLD_Y.OPTIONS_STR]))
--     self.subscreener.sub_screens["MYI"].shadowsSpinner:SetSelectedIndex(EnabledOptionsIndex(self.working[_G.MYI.SETTINGS.OPTIONS.SHADOWS.OPTIONS_STR]))

--     old_OptionsScreen_InitializeSpinners(self, ...)
-- end