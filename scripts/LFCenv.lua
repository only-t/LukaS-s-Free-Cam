-- Defined this way to make reusing for different mods easier
local MOD_CODE = "LFC"
local MOD_NAME = "LukaS's Free Cam"

-- Good to define your entire environment in a special table.
-- Eliminates any potential mod incompatability with mods that use the same global names.
-- Unless they define a global of the same name as `MOD_CODE` i guess...
_G[MOD_CODE] = {
    MOD_CODE = MOD_CODE,
    MOD_NAME = MOD_NAME
}

---
--- Created specifically to print lines with a clear source, that being, the mod.
--- Functionally, it's a simple print with a prefix which can be defined either as a `PRINT`, a `WARN` or an `ERROR`.
---
--- Any additional parameters after `mainline` will be printed with an indentation.
---@param print_type int
---@param mainline any
---@vararg any
---@return void
local function modprint(print_type, mainline, ...)
    if mainline == nil then
        return
    end

    mainline = tostring(mainline)

    if print_type == _G[MOD_CODE].PRINT then
        print(_G[MOD_CODE].PRINT_PREFIX..mainline)
    elseif print_type == _G[MOD_CODE].WARN then
        print(_G[MOD_CODE].WARN_PREFIX..mainline)
    elseif print_type == _G[MOD_CODE].ERROR then
        print(_G[MOD_CODE].ERROR_PREFIX..mainline)
    end

    for _, line in ipairs({...}) do
        print("    "..tostring(line))
    end

    print("")
end

---
--- A custom assert that prints the mods special error message with the `ERROR` prefix.
--- The assertion fails after all provided lines are printed, assuming `cond` is `false`.
---
--- Any additional parameters after `mainline` will be printed with an indentation.
---@param cond bool
---@param mainline any
---@vararg any
---@return void
local function modassert(cond, mainline, ...)
    if not cond then
        modprint(_G[MOD_CODE].ERROR_PREFIX, mainline, ...)

        _G.error("Assertion failed!")
    end
end

---
--- Saves `data` as a persistent json string using `TheSim:SetPersistentString()`. The string is saved inside `filename`.
--- Currently only tested on client-sided mods.
---
--- `data` can be either a Lua table or a json string.
---
--- `cb` is an optional function that will run after a successful string save.
---@param filename string
---@param data table|str
---@param cb function
---@return void
local function ModSetPersistentData(filename, data, cb)
    if type(data) == "table" then
        data = _G.json.encode(data)
    elseif type(data) ~= "string" then
        modassert(false, "Failed to save persistent data!", "Data provided is neither a table nor a string!")
    end
    
    if cb == nil or type(cb) ~= "function" then
        _G.TheSim:SetPersistentString(filename, data, false)
        return
    end

    _G.TheSim:SetPersistentString(filename, data, false, cb)
end

---
--- Retrieves persistent data as a json string from `filename`.
--- Currently only tested on client-sided mods.
---
--- `cb` runs with 2 parameters: `success`, a boolean, and `data`, the json string. If `success` is `false` `data` is an empty string.
---@param filename string
---@param cb function
---@return void
local function ModGetPersistentData(filename, cb)
    modassert(type(cb) == "function", "Failed to load persistent data!", "cb needs to be a function!")
    _G.TheSim:GetPersistentString(filename, cb)
end

---
--- Retrieves current mod setting using `setting_id`. Will print a message if `setting_id` doesn't exist.
---@param setting_id string
---@return table
local function GetModSetting(setting_id)
    if _G[MOD_CODE].CURRENT_SETTINGS[setting_id] ~= nil then
        return _G[MOD_CODE].CURRENT_SETTINGS[setting_id]
    end

    modprint(_G[MOD_CODE].PRINT, "Trying to get mod setting "..tostring(setting_id).." but it does not seem to exist.")
end

-- [[ Disable for live builds ]]
_G[MOD_CODE].DEV = true

-- [[ Universal Variables ]]
_G[MOD_CODE].PRINT = 0
_G[MOD_CODE].WARN = 1
_G[MOD_CODE].ERROR = 2
_G[MOD_CODE].PRINT_PREFIX = "["..MOD_CODE.."] "..MOD_NAME.." - "
_G[MOD_CODE].WARN_PREFIX = "["..MOD_CODE.."] "..MOD_NAME.." - WARNING! "
_G[MOD_CODE].ERROR_PREFIX = "["..MOD_CODE.."] "..MOD_NAME.." - ERROR! "

_G[MOD_CODE].modprint = modprint
_G[MOD_CODE].modassert = modassert
_G[MOD_CODE].modsetpersistentdata = ModSetPersistentData
_G[MOD_CODE].modgetpersistentdata = ModGetPersistentData
_G[MOD_CODE].GetModSetting = GetModSetting


-- [[                                             ]] --
-- [[ Here is where mod specific env variables go ]] --
-- [[                                             ]] --

-- [[ Constants ]]
_G[MOD_CODE].MIN_CAM_Y = 1.35 -- 1.35 is about the smallest value to keep the camera from clipping into the ground
_G[MOD_CODE].MAX_CAM_Y = 100

_G[MOD_CODE].MIN_FOV = 30
_G[MOD_CODE].MAX_FOV = 120

_G[MOD_CODE].MIN_SENSITIVITY = 1
_G[MOD_CODE].MAX_SENSITIVITY = 20

_G[MOD_CODE].MAX_SPEED_INDEX = 10

-- [[ Mod Settings ]] -- Not to be confused with configuration_options.
                      -- These show up in Game Options and can be updated during gameplay.
local enableDisableOptions = {
    { text = _G.STRINGS.UI.OPTIONS.DISABLED, data = false },
    { text = _G.STRINGS.UI.OPTIONS.ENABLED,  data = true  }
}

_G[MOD_CODE].SETTING_TYPES = {
    SPINNER = "spinner",
    NUM_SPINNER = "num_spinner",
    LIST = "list",
    KEY_SELECT = "key_select"
}

_G[MOD_CODE].MOD_SETTINGS = {
    FILENAME = "LFC_settings",
    TAB_NAME = "LukaS's Free Cam",
    TOOLTIP = "Modify the mods settings",
    SETTINGS = {
        SENSITIVITY = {
            ID = "LFC_sensitivity",
            SPINNER_TITLE = "Sensitivity:",
            TOOLTIP = "Change the cameras look sensitivity.",
            COLUMN = 1,
            TYPE = _G[MOD_CODE].SETTING_TYPES.NUM_SPINNER,
            VALUES = { _G[MOD_CODE].MIN_SENSITIVITY, _G[MOD_CODE].MAX_SENSITIVITY, 1 },
            DEFAULT = 10
        },
        LIMITED = {
            ID = "LFC_limited",
            SPINNER_TITLE = "Limited movement:",
            TOOLTIP = "Blocks the camera from going too far up or below the ground.",
            COLUMN = 1,
            TYPE = _G[MOD_CODE].SETTING_TYPES.SPINNER,
            VALUES = enableDisableOptions,
            DEFAULT = false
        },
        FOV = {
            ID = "LFC_fov",
            SPINNER_TITLE = "FOV:",
            TOOLTIP = "Change the cameras field of view.",
            COLUMN = 1,
            TYPE = _G[MOD_CODE].SETTING_TYPES.NUM_SPINNER,
            VALUES = { _G[MOD_CODE].MIN_FOV, _G[MOD_CODE].MAX_FOV, 5 },
            DEFAULT = 80
        },
        TOGGLE_KEY = {
            ID = "LFC_toggle_key",
            SPINNER_TITLE = "Toggle camera key:",
            TOOLTIP = "Change the key for toggling Free Cam.",
            COLUMN = 2,
            TYPE = _G[MOD_CODE].SETTING_TYPES.KEY_SELECT,
            DEFAULT = _G.KEY_EQUALS
        }
    }
}

_G[MOD_CODE].CURRENT_SETTINGS = {  }

-- [[ Misc. Variables ]]
_G[MOD_CODE].LFCFreeCamera = nil -- The camera gets created with TheGlobalInstance

_G[MOD_CODE].UpdateCameraSettings = function()
    _G[MOD_CODE].modassert(_G[MOD_CODE].LFCFreeCamera ~= nil, "Cannot update camera settings!", "LFCFreeCamera is nil!")

    _G[MOD_CODE].LFCFreeCamera:SetSensitivity(_G[MOD_CODE].GetModSetting(_G[MOD_CODE].MOD_SETTINGS.SETTINGS.SENSITIVITY.ID))
    _G[MOD_CODE].LFCFreeCamera:SetFOV(_G[MOD_CODE].GetModSetting(_G[MOD_CODE].MOD_SETTINGS.SETTINGS.FOV.ID))
    _G[MOD_CODE].LFCFreeCamera:SetLimited(_G[MOD_CODE].GetModSetting(_G[MOD_CODE].MOD_SETTINGS.SETTINGS.LIMITED.ID))
end

_G[MOD_CODE].SelectFreeCam = function()
    if _G.ThePlayer then -- Only doable in game with an existing player
        _G.TheCamera = _G[MOD_CODE].LFCFreeCamera
        _G.ThePlayer.components.playercontroller:Enable(false)
    end
end

_G[MOD_CODE].SelectDSTCam = function()
    if _G.ThePlayer then -- Only doable in game with an existing player
        _G.TheCamera = _G.DSTFollowCamera
        _G.ThePlayer.components.playercontroller:Enable(true)
    end
end