require("mathutil")

-- When onupdatefn is set to nil, use dummyfn instead.
-- This way we don't need to check for nil in the update loop.
-- It's more optimized because there's always an actual onupdatefn
-- when the world is live and performance does matter.
local function dummyfn() end

local function normalize(angle)
    while angle > 360 do
        angle = angle - 360
    end

    while angle < 0 do
        angle = angle + 360
    end

    return angle
end

local function RunFnWarning(fnname) -- For functions with no use for LFCFreeCamera, have to keep them in case mods use them but we'll give them a warning
    LFC.modassert(type(fnname) == "string", "fnname needs to be a string!")

    local info = debug.getinfo(3, "S")
    if info.source then
        local workshop_str = string.find(info.source, "workshop%-")
        if workshop_str ~= nil or (LFC.DEV and string.find(info.source, "LukaS%-s%-Free%-Cam")) then
            LFC.modprint(LFC.MOD_WARN,
                "Trying to run a FollowCamera function ["..fnname.." at "..info.source..", line "..info.linedefined.."] while LFCFreeCamera is selected!",
                "This function is not present in the LFCFreeCamera class!",
                "This is just a warning!"
            )
        end
    end
end

local function OnZoomControl(control, digitalvalue)
    if digitalvalue then
        if control == CONTROL_ZOOM_IN then
            TheCamera:SpeedUp()
        end

        if control == CONTROL_ZOOM_OUT then
            TheCamera:SpeedDown()
        end
    end
end

local speed_i = 3
local LFCFreeCamera = Class(function(self)
    self.currentpos = Vector3(0, 0, 0)
    self.moving = Vector3(0, 0, 0) -- Direction the camera is supposed to move in
    self.speeds = { 2, 4, 8, 16, 24, 32, 40, 52, 64 } -- Different speeds because it's easier to create a satisfying speed curve that way
    self.sensitivity = 10

    self.fov = 80 -- Higher looks better for first person
    self.pitch = 0
    self.heading = 0

    self.updatelisteners = {  }

    self.update_paused = false
    self.controllable = true
    self.limited = true -- Limits how far the camera can travel vertically

    self:SetDefault()

    self.onupdatefn = dummyfn

    TheInput:AddControlHandler(CONTROL_ZOOM_IN, function(digitalvalue) OnZoomControl(CONTROL_ZOOM_IN, digitalvalue) end)
    TheInput:AddControlHandler(CONTROL_ZOOM_OUT, function(digitalvalue) OnZoomControl(CONTROL_ZOOM_OUT, digitalvalue) end)
end)

function LFCFreeCamera:SetDefaultOffset()
    RunFnWarning("SetDefaultOffset()")
end

function LFCFreeCamera:SetDefault()
    RunFnWarning("SetDefault()")
end

function LFCFreeCamera:GetRightVec()
    local right = (self.heading + 90) * DEGREES
    return Vector3(math.cos(right), 0, math.sin(right))
end

function LFCFreeCamera:GetDownVec()
    local heading = self.heading * DEGREES
    return Vector3(math.cos(heading), 0, math.sin(heading))
end

function LFCFreeCamera:GetPitchDownVec()
    local pitch = self.pitch * DEGREES
    local heading = self.heading * DEGREES
    local cos_pitch = -math.cos(pitch)
    local cos_heading = math.cos(heading)
    local sin_heading = math.sin(heading)
    return Vector3(cos_pitch * cos_heading, -math.sin(pitch), cos_pitch * sin_heading)
end

function LFCFreeCamera:SetPaused(val)
    RunFnWarning("SetPaused()")
end

function LFCFreeCamera:SetMinDistance()
    RunFnWarning("SetMinDistance()")
end

function LFCFreeCamera:SetMaxDistance()
    RunFnWarning("SetMaxDistance()")
end

function LFCFreeCamera:SetExtraMaxDistance()
    RunFnWarning("SetExtraMaxDistance()")
end

function LFCFreeCamera:SetGains()
    RunFnWarning("SetGains()")
end

function LFCFreeCamera:GetGains()
    RunFnWarning("GetGains()")

    return 0, 0, 0
end

function LFCFreeCamera:IsControllable()
    return self.controllable
end

function LFCFreeCamera:SetControllable(val)
    self.controllable = val
end

function LFCFreeCamera:CanControl()
    return self.controllable
end

function LFCFreeCamera:SetOffset()
    RunFnWarning("SetOffset()")
end

function LFCFreeCamera:PushScreenHOffset()
    RunFnWarning("PushScreenHOffset()")
end

function LFCFreeCamera:PopScreenHOffset()
    RunFnWarning("PopScreenHOffset()")
end

function LFCFreeCamera:LockDistance()
    RunFnWarning("LockDistance()")
end

function LFCFreeCamera:GetDistance()
    RunFnWarning("GetDistance()")

    return 0
end

function LFCFreeCamera:SetDistance()
    RunFnWarning("SetDistance()")
end

function LFCFreeCamera:Shake()
    RunFnWarning("Shake()")
end

function LFCFreeCamera:SetTarget()
    RunFnWarning("SetTarget()")
end

function LFCFreeCamera:MaximizeDistance()
    RunFnWarning("MaximizeDistance()")
end

function LFCFreeCamera:Apply()
    local pitch = self.pitch * DEGREES
    local heading = self.heading * DEGREES
    local right = (self.heading + 90) * DEGREES
    local cos_pitch = math.cos(pitch)
    local cos_heading = math.cos(heading)
    local sin_heading = math.sin(heading)

    -- Dir
    local dx = -cos_pitch * cos_heading
    local dy = -math.sin(pitch)
    local dz = -cos_pitch * sin_heading

    -- Right
    local rx = math.cos(right)
    local ry = 0
    local rz = math.sin(right)

    -- Up
    local ux = dy * rz - dz * ry
    local uy = dz * rx - dx * rz
    local uz = dx * ry - dy * rx

    TheSim:SetCameraPos(self.currentpos.x, self.currentpos.y, self.currentpos.z)
    TheSim:SetCameraDir(dx, dy, dz)
    TheSim:SetCameraUp(ux, uy, uz)
    TheSim:SetCameraFOV(self.fov)

    -- local listendist = -0.1 * self.distance
    -- TheSim:SetListener(
    --     dx * listendist + self.currentpos.x,
    --     dy * listendist + self.currentpos.y,
    --     dz * listendist + self.currentpos.z,
    --     dx, dy, dz,
    --     ux, uy, uz
    -- )
end

function LFCFreeCamera:GetHeading()
    return self.heading
end

function LFCFreeCamera:GetHeadingTarget()
    RunFnWarning("GetHeadingTarget()")

    return 0
end

function LFCFreeCamera:SetHeadingTarget()
    RunFnWarning("SetHeadingTarget()")
end

function LFCFreeCamera:SetContinuousHeadingTarget()
    RunFnWarning("SetContinuousHeadingTarget()")
end

function LFCFreeCamera:ContinuousZoomDelta()
    RunFnWarning("ContinuousZoomDelta()")
end

function LFCFreeCamera:ZoomIn()
    RunFnWarning("ZoomIn()")
end

function LFCFreeCamera:ZoomOut()
    RunFnWarning("ZoomOut()")
end

function LFCFreeCamera:Snap()
    RunFnWarning("Snap()")
end

function LFCFreeCamera:CutsceneMode()
    RunFnWarning("CutsceneMode()")
end

function LFCFreeCamera:SetCustomLocation()
    RunFnWarning("SetCustomLocation()")
end

function LFCFreeCamera:SetMovingDir(x, y, z)
    if type(x) == "number" then
        self.moving = Vector3(x, y, z)
    else
        self.moving = x
    end
end

function LFCFreeCamera:SetLimited(limited)
    self.limited = limited
end

function LFCFreeCamera:SetSensitivity(sensitivity)
    self.sensitivity = math.max(0, sensitivity)
end

function LFCFreeCamera:SetFOV(fov)
    self.fov = math.clamp(fov, 30, 120)
end

function LFCFreeCamera:SpeedUp()
    speed_i = math.clamp(speed_i + 1, 1, #self.speeds)
end

function LFCFreeCamera:SpeedDown()
    speed_i = math.clamp(speed_i - 1, 1, #self.speeds)
end

function LFCFreeCamera:Update(dt)
    if ThePlayer then
        local enabled, ishudblocking = ThePlayer.components.playercontroller:IsEnabled()

        if not enabled or ishudblocking then
            return
        end
    end

    local w, h = TheSim:GetWindowSize()
    local old_screen_x, old_screen_y = math.floor(w / 2), math.floor(h / 2)
    local screen_x, screen_y = TheSim:GetPosition()
    screen_y = screen_y - 1 -- tf?

    local heading_move = (screen_x - old_screen_x) * dt
    local pitch_move = (screen_y - old_screen_y) * dt
    heading_move = heading_move * self.sensitivity
    pitch_move = pitch_move * self.sensitivity

    self.heading = normalize(self.heading - heading_move) -- But why is it to the left tho ;_; Klei please...
    self.pitch = math.clamp(self.pitch - pitch_move, -89 , 89)

    local heading = self.heading * DEGREES
    local pitch = self.pitch * DEGREES
    local dir_cos = math.cos(heading)
    local dir_sin = math.sin(heading)
    local p_cos = math.cos(pitch)
    local p_sin = math.sin(pitch)

    local length = self.moving:Length()
    if length ~= 0 then
        local pos_move = Vector3(0, 0, 0) -- Why is -X the forward axis, I am going insane
        pos_move.x = -(self.moving.x * dir_sin + self.moving.z * p_cos * dir_cos + self.moving.y * p_sin * dir_cos) / length
        pos_move.y = (-self.moving.z * p_sin + self.moving.y * p_cos) / length
        pos_move.z = (self.moving.x * dir_cos - self.moving.z * p_cos * dir_sin - self.moving.y * p_sin * dir_sin) / length

        self.currentpos = self.currentpos + pos_move * self.speeds[speed_i] * dt
        if self.limited then
            self.currentpos.y = math.clamp(self.currentpos.y, LFC.MIN_CAM_Y, LFC.MAX_CAM_Y)
        end
    end

    TheInputProxy:SetOSCursorPos(math.floor(w / 2), math.floor(h / 2))

    self:onupdatefn(dt)
    self:Apply()
    self:UpdateListeners(dt)
end

function LFCFreeCamera:UpdateListeners(dt)
    for src, cbs in pairs(self.updatelisteners) do
        for _, fn in ipairs(cbs) do
            fn(dt)
        end
    end
end

function LFCFreeCamera:SetOnUpdateFn(fn)
    self.onupdatefn = fn or dummyfn
end

function LFCFreeCamera:AddListener(src, cb)
    if self.updatelisteners[src] ~= nil then
        table.insert(self.updatelisteners[src], cb)
    else
        self.updatelisteners[src] = { cb }
    end
end

function LFCFreeCamera:RemoveListener(src, cb)
    if self.updatelisteners[src] ~= nil then
        if cb ~= nil then
            table.removearrayvalue(self.updatelisteners[src], cb)
            if #self.updatelisteners[src] > 0 then
                return
            end
        end
        self.updatelisteners[src] = nil
    end
end

return LFCFreeCamera
