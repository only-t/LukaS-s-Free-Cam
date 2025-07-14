local function modprint(print_type, mainline, ...)
    if mainline == nil then
        return
    end

    _G.assert(type(mainline) == "string", "mainline has to be a string!")

    if print_type == _G.LFC.PRINT then
        print(_G.LFC.PRINT_PREFIX..mainline)
    elseif print_type == _G.LFC.WARN then
        print(_G.LFC.WARN_PREFIX..mainline)
    elseif print_type == _G.LFC.ERROR then
        print(_G.LFC.ERROR_PREFIX..mainline)
    end

    for _, line in ipairs({...}) do
        print("    "..line)
    end

    print("")
end

local function modassert(cond, mainline, ...)
    if not cond then
        print(_G.LFC.ERROR_PREFIX..mainline)
        for _, line in ipairs({...}) do
            print("    "..line)
        end

        _G.error("Assertion failed!")
    end
end


_G.LFC = {
    DEV = true,

    -- Utility
    MOD_PRINT = 0,
    MOD_WARN = 1,
    MOD_ERROR = 2,
    PRINT_PREFIX = "[LFC] LukaS's Free Cam - ",
    WARN_PREFIX = "[LFC] LukaS's Free Cam - WARNING! ",
    ERROR_PREFIX = "[LFC] LukaS's Free Cam - ERROR! ",

    modprint = modprint,
    modassert = modassert,

    -- Constants
    MIN_CAM_Y = 1.35, -- 1.35 is about the smallest value to keep the camera from clipping into the ground
    MAX_CAM_Y = 100,

    MIN_FOV = 30,
    MAX_FOV = 120,
    
    -- Mod settings
    SETTINGS = {
        NAME = "LukaS's Free Cam",
        TOOLTIP = "Modify the mods settings",
        OPTIONS = {
            SENSITIVITY = {
                NAME = "Sensitivity:",
                OPTIONS_STR = "freecam_sensitivity",
                TOOLTIP = "Change the cameras look sensitivity.",
                DEFAULT = 10
            },
            LIMITED = {
                NAME = "Limited movement:",
                OPTIONS_STR = "freecam_limited",
                TOOLTIP = "Blocks the camera from going too far up or below the ground.",
                DEFAULT = false
            },
            FOV = {
                NAME = "FOV:",
                OPTIONS_STR = "freecam_fov",
                TOOLTIP = "Change the cameras field of view.",
                DEFAULT = 80
            }
        }
    }
}