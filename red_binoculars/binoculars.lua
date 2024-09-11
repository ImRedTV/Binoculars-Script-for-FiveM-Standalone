-- Binoculars Script for FiveM (Standalone)
-- Created by RED

-- CONFIG --
local fov_max = 70.0
local fov_min = 5.0 -- max zoom level (smaller fov is more zoom)
local zoomspeed = 5.5 -- camera zoom speed (faster zoom)
local speed_lr = 8.0 -- speed by which the camera pans left-right
local speed_ud = 8.0 -- speed by which the camera pans up-down
local mode = 0 -- 0 = Normal, 1 = Thermal, 2 = Night Vision

local fov = (fov_max + fov_min) * 0.5
local hasBinoculars = false -- Default to false, to be enabled via command
local enableCommand = true -- Toggle this to enable or disable the /binoculars command for debug

local Keys = {
    ["G"] = 47, 
    ["BACKSPACE"] = 177,
    ["SCROLLUP"] = 241, 
    ["SCROLLDOWN"] = 242,
    ["LSHIFT"] = 21
}

local keybindEnabled = true -- When enabled, binoculars are available by keybind
local binocularKey = Keys["G"]
local storeBinocularKey = Keys["BACKSPACE"]
local modeSwitchKey = Keys["LSHIFT"]

-- Command to toggle binoculars usage for debug
if enableCommand then
    RegisterCommand("binoculars", function()
        hasBinoculars = not hasBinoculars
        local status = hasBinoculars and "enabled" or "disabled"
        print("Binoculars " .. status)
        TriggerEvent('chat:addMessage', {
            args = { "Binoculars " .. status }
        })
    end, false)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- Check every frame

        local lPed = PlayerPedId()

        -- Detect if binocular key is pressed
        if keybindEnabled and IsControlJustReleased(1, binocularKey) then
            print("Binocular key pressed") -- Debugging output
            if hasBinoculars then
                ActivateBinoculars(lPed)
            end
        end
    end
end)

function ActivateBinoculars(lPed)
    if not IsPedSittingInAnyVehicle(lPed) and hasBinoculars then
        -- Debugging output
        print("Activating binoculars")

        -- Start binoculars animation
        TaskStartScenarioInPlace(lPed, "WORLD_HUMAN_BINOCULARS", 0, true)
        Citizen.Wait(2000) -- Wait for the animation to start

        SetTimecycleModifier("default")
        SetTimecycleModifierStrength(0.3)

        local scaleform = RequestScaleformMovie("BINOCULARS")
        while not HasScaleformMovieLoaded(scaleform) do
            Citizen.Wait(10)
        end

        local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
        AttachCamToEntity(cam, lPed, 0.0, 0.0, 1.0, true)
        SetCamRot(cam, 0.0, 0.0, GetEntityHeading(lPed))
        SetCamFov(cam, fov)
        RenderScriptCams(true, false, 0, true, false)
        PushScaleformMovieFunction(scaleform, "SET_CAM_LOGO")
        PushScaleformMovieFunctionParameterInt(0)
        PopScaleformMovieFunctionVoid()

        binoculars = true

        while binoculars and not IsEntityDead(lPed) do
            if IsControlJustPressed(0, storeBinocularKey) then
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                DeactivateBinoculars(lPed, cam, scaleform)
                return
            end

            if IsControlJustPressed(0, modeSwitchKey) then
                mode = (mode + 1) % 3
                UpdateVisionMode()
            end

            local zoomvalue = (1.0 / (fov_max - fov_min)) * (fov - fov_min)
            CheckInputRotation(cam, zoomvalue)
            HandleZoom(cam)
            HideHUDThisFrame()

            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
            Citizen.Wait(10)
        end

        DeactivateBinoculars(lPed, cam, scaleform)
    end
end

function DeactivateBinoculars(lPed, cam, scaleform)
    binoculars = false
    ClearTimecycleModifier()
    fov = (fov_max + fov_min) * 0.5
    RenderScriptCams(false, false, 0, true, false)
    SetScaleformMovieAsNoLongerNeeded(scaleform)
    DestroyCam(cam, false)
    SetNightvision(false)
    SetSeethrough(false)
    
    -- Stop binoculars animation
    ClearPedTasks(lPed)
end

function HideHUDThisFrame()
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
    HideHudComponentThisFrame(1) -- Wanted Stars
    HideHudComponentThisFrame(2) -- Weapon icon
    HideHudComponentThisFrame(3) -- Cash
    HideHudComponentThisFrame(4) -- MP CASH
    HideHudComponentThisFrame(6) -- Weapon Wheel
    HideHudComponentThisFrame(7) -- Vehicle
    HideHudComponentThisFrame(8) -- 2D Map
    HideHudComponentThisFrame(9) -- Compass
    HideHudComponentThisFrame(13) -- Cash Change
    HideHudComponentThisFrame(11) -- Floating Help Text
    HideHudComponentThisFrame(12) -- More Floating Help Text
    HideHudComponentThisFrame(15) -- Subtitle Text
    HideHudComponentThisFrame(18) -- Game Stream
    HideHudComponentThisFrame(19) -- Weapon Wheel
    HideHudComponentThisFrame(20) -- Area Name
end

function DrawHUD()
    -- Draws the HUD information only if binoculars are active
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString("Zoom: " .. string.format("%.1f", fov) .. "\nMode: " .. GetVisionMode())
    DrawText(0.02, 0.85)
end

function GetVisionMode()
    if mode == 0 then
        return "Normal"
    elseif mode == 1 then
        return "Thermal"
    elseif mode == 2 then
        return "Night Vision"
    end
end

function UpdateVisionMode()
    if mode == 0 then
        SetNightvision(false)
        SetSeethrough(false)
    elseif mode == 1 then
        SetNightvision(false)
        SetSeethrough(true)
    elseif mode == 2 then
        SetNightvision(true)
        SetSeethrough(false)
    end
end

function CheckInputRotation(cam, zoomvalue)
    local rightAxisX = GetDisabledControlNormal(0, 220)
    local rightAxisY = GetDisabledControlNormal(0, 221)
    local rotation = GetCamRot(cam, 2)
    if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
        local new_z = rotation.z + rightAxisX * -1.0 * speed_ud * (zoomvalue + 0.1)
        local new_x = math.max(math.min(20.0, rotation.x + rightAxisY * -1.0 * speed_lr * (zoomvalue + 0.1)), -89.5)
        SetCamRot(cam, new_x, 0.0, new_z, 2)
    end
end

function HandleZoom(cam)
    local lPed = PlayerPedId()
    if not IsPedSittingInAnyVehicle(lPed) then
        if IsControlJustPressed(0, Keys["SCROLLUP"]) then
            fov = math.max(fov - zoomspeed, fov_min)
        end
        if IsControlJustPressed(0, Keys["SCROLLDOWN"]) then
            fov = math.min(fov + zoomspeed, fov_max)
        end
        local current_fov = GetCamFov(cam)
        if math.abs(fov - current_fov) < 0.1 then
            fov = current_fov
        end
        SetCamFov(cam, current_fov + (fov - current_fov) * 0.05)
    end
end
