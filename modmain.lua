env._G = GLOBAL._G
GLOBAL.setfenv(1, env)

Assets = {  }
PrefabFiles = {  }

modimport("scripts/LFCenv")

if _G.LFC.DEV then
    _G.LFC.inspect = require("inspect")
end

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

local LFCSettingsTab = require("widgets/LFCsettingstab")
local OptionsScreen = require("screens/redux/optionsscreen")
local old_OptionsScreen_BuildMenu = OptionsScreen._BuildMenu
OptionsScreen._BuildMenu = function(self, subscreener, ...)
    subscreener.sub_screens["LFC"] = self.panel_root:AddChild(LFCSettingsTab(self))
    local menu = old_OptionsScreen_BuildMenu(self, subscreener, ...)

	local lfc_button = subscreener:MenuButton(_G.LFC.SETTINGS.NAME, "LFC", _G.LFC.SETTINGS.TOOLTIP, self.tooltip)
    menu:AddCustomItem(lfc_button)
    local pos = _G.Vector3(0, 0, 0)
    pos.y = pos.y + menu.offset * (#menu.items - 1)
    lfc_button:SetPosition(pos)
    
    return menu
end

local function EnabledOptionsIndex(enabled)
    return enabled and 2 or 1
end

if _G.Profile:GetValue(_G.LFC.SETTINGS.OPTIONS.SENSITIVITY.OPTIONS_STR) == nil then
    _G.Profile:SetValue(_G.LFC.SETTINGS.OPTIONS.SENSITIVITY.OPTIONS_STR, _G.LFC.SETTINGS.OPTIONS.SENSITIVITY.DEFAULT)
end

if _G.Profile:GetValue(_G.LFC.SETTINGS.OPTIONS.FOV.OPTIONS_STR) == nil then
    _G.Profile:SetValue(_G.LFC.SETTINGS.OPTIONS.FOV.OPTIONS_STR, _G.LFC.SETTINGS.OPTIONS.FOV.DEFAULT)
end

if _G.Profile:GetValue(_G.LFC.SETTINGS.OPTIONS.LIMITED.OPTIONS_STR) == nil then
    _G.Profile:SetValue(_G.LFC.SETTINGS.OPTIONS.LIMITED.OPTIONS_STR, _G.LFC.SETTINGS.OPTIONS.LIMITED.DEFAULT)
end

local old_OptionsScreen_DoInit = OptionsScreen.DoInit
OptionsScreen.DoInit = function(self, ...)
    self.options[_G.LFC.SETTINGS.OPTIONS.SENSITIVITY.OPTIONS_STR] = _G.Profile:GetValue(_G.LFC.SETTINGS.OPTIONS.SENSITIVITY.OPTIONS_STR)
    self.working[_G.LFC.SETTINGS.OPTIONS.SENSITIVITY.OPTIONS_STR] = _G.Profile:GetValue(_G.LFC.SETTINGS.OPTIONS.SENSITIVITY.OPTIONS_STR)

    self.options[_G.LFC.SETTINGS.OPTIONS.FOV.OPTIONS_STR] = _G.Profile:GetValue(_G.LFC.SETTINGS.OPTIONS.FOV.OPTIONS_STR)
    self.working[_G.LFC.SETTINGS.OPTIONS.FOV.OPTIONS_STR] = _G.Profile:GetValue(_G.LFC.SETTINGS.OPTIONS.FOV.OPTIONS_STR)

    self.options[_G.LFC.SETTINGS.OPTIONS.LIMITED.OPTIONS_STR] = _G.Profile:GetValue(_G.LFC.SETTINGS.OPTIONS.LIMITED.OPTIONS_STR)
    self.working[_G.LFC.SETTINGS.OPTIONS.LIMITED.OPTIONS_STR] = _G.Profile:GetValue(_G.LFC.SETTINGS.OPTIONS.LIMITED.OPTIONS_STR)

    _G.LFCFreeCamera:SetSensitivity(self.working[_G.LFC.SETTINGS.OPTIONS.SENSITIVITY.OPTIONS_STR])
    _G.LFCFreeCamera:SetFOV(self.working[_G.LFC.SETTINGS.OPTIONS.FOV.OPTIONS_STR])
    _G.LFCFreeCamera:SetLimited(self.working[_G.LFC.SETTINGS.OPTIONS.LIMITED.OPTIONS_STR])

    old_OptionsScreen_DoInit(self, ...)
end

local old_OptionsScreen_Apply = OptionsScreen.Apply
OptionsScreen.Apply = function(self, ...)
    _G.Profile:SetValue(_G.LFC.SETTINGS.OPTIONS.SENSITIVITY.OPTIONS_STR, self.working[_G.LFC.SETTINGS.OPTIONS.SENSITIVITY.OPTIONS_STR])
    _G.Profile:SetValue(_G.LFC.SETTINGS.OPTIONS.FOV.OPTIONS_STR, self.working[_G.LFC.SETTINGS.OPTIONS.FOV.OPTIONS_STR])
    _G.Profile:SetValue(_G.LFC.SETTINGS.OPTIONS.LIMITED.OPTIONS_STR, self.working[_G.LFC.SETTINGS.OPTIONS.LIMITED.OPTIONS_STR])

    _G.LFCFreeCamera:SetSensitivity(self.working[_G.LFC.SETTINGS.OPTIONS.SENSITIVITY.OPTIONS_STR])
    _G.LFCFreeCamera:SetFOV(self.working[_G.LFC.SETTINGS.OPTIONS.FOV.OPTIONS_STR])
    _G.LFCFreeCamera:SetLimited(self.working[_G.LFC.SETTINGS.OPTIONS.LIMITED.OPTIONS_STR])

    old_OptionsScreen_Apply(self, ...)
end

local old_OptionsScreen_InitializeSpinners = OptionsScreen.InitializeSpinners
OptionsScreen.InitializeSpinners = function(self, ...)
    self.subscreener.sub_screens["LFC"].sensitivitySpinner:SetSelectedIndex(math.floor(self.working[_G.LFC.SETTINGS.OPTIONS.SENSITIVITY.OPTIONS_STR] + 0.5))
    self.subscreener.sub_screens["LFC"].fovSpinner:SetSelectedIndex(self.working[_G.LFC.SETTINGS.OPTIONS.FOV.OPTIONS_STR] / 5 - 5)
    self.subscreener.sub_screens["LFC"].limitedSpinner:SetSelectedIndex(EnabledOptionsIndex(self.working[_G.LFC.SETTINGS.OPTIONS.LIMITED.OPTIONS_STR]))

    old_OptionsScreen_InitializeSpinners(self, ...)
end