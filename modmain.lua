env._G = GLOBAL._G
GLOBAL.setfenv(1, env)

Assets = {  }
PrefabFiles = {  }

-- [[ Mod environment ]]
modimport("scripts/LFCenv")

if _G.LFC.DEV then
    _G.LFC.inspect = require("inspect")
end
--

-- Custom settings because configuration_options are annoying to use
modimport("scripts/LFCmodsettings")

-- [[ Misc. changes ]]
local old_CreateEntity = _G.CreateEntity
_G.CreateEntity = function(name, ...)
    local ent = old_CreateEntity(name, ...)

    if name == "TheGlobalInstance" then
        _G.global("DSTFollowCamera") -- Because of "strict" global rules set up by strict.lua
        _G.DSTFollowCamera = _G.TheCamera -- The original camera gets stored so we can switch between them
        _G.LFC.LFCFreeCamera = require("cameras/LFCfreecamera")()
    end

    return ent
end

local PlayerController = require("components/playercontroller")
local old_DoCameraControl = PlayerController.DoCameraControl
PlayerController.DoCameraControl = function(self, ...)
    if not _G.TheCamera:CanControl() then
        return
    end

    if _G.ThePlayer.HUD:HasInputFocus() then
        return
    end

    if _G.TheCamera == _G.LFC.LFCFreeCamera then
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
--