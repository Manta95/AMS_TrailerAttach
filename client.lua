if not ConfigTrailer.AnyTrailerAttach then return end

local SLEEP_IDLE = 3000
local SLEEP_ACTIVE = 1000
local PREFILTER_RANGE = 15.0 -- distance max entre l'attelage et l'origine d'une remorque avant de lire ses bones

local radius = ConfigTrailer.DistanceFromTowHitch
local maxSpeed = ConfigTrailer.MaxSpeedForAttach / 3.6
local detachCooldown = ConfigTrailer.AfterDetachCooldown

local currentVehicle = 0
local hitchBone = -1
local wasAttached = false
local lastDetachTime = 0
local blockedTrailer = nil -- remorque qui vient d'etre detachee, ignoree tant qu'elle reste a portee

local function isTrailerInRange(trailer, hitchCoords)
    local boneIndex = GetEntityBoneIndexByName(trailer, "attach_male")
    return boneIndex ~= -1 and #(GetWorldPositionOfEntityBone(trailer, boneIndex) - hitchCoords) < radius
end

local function findTrailerNear(vehicle, hitchCoords)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if veh ~= vehicle and veh ~= blockedTrailer
            and #(GetEntityCoords(veh) - hitchCoords) < PREFILTER_RANGE
            and isTrailerInRange(veh, hitchCoords)
            and GetVehicleType(veh) == "trailer" then
            return veh
        end
    end
end

CreateThread(function()
    while true do
        local sleep = SLEEP_IDLE
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle ~= currentVehicle then
            currentVehicle = vehicle
            hitchBone = vehicle ~= 0 and GetEntityBoneIndexByName(vehicle, "attach_female") or -1
            wasAttached = false
            blockedTrailer = nil
        end

        if hitchBone ~= -1 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            sleep = SLEEP_ACTIVE
            local attached, attachedTrailer = GetVehicleTrailerVehicle(vehicle)

            if attached then
                wasAttached = true
                blockedTrailer = attachedTrailer
            else
                if wasAttached then
                    wasAttached = false
                    lastDetachTime = GetGameTimer()
                end

                local hitchCoords = GetWorldPositionOfEntityBone(vehicle, hitchBone)

                -- La remorque detachee redevient attelable des que l'attelage s'en est eloigne
                if blockedTrailer and (not DoesEntityExist(blockedTrailer) or not isTrailerInRange(blockedTrailer, hitchCoords)) then
                    blockedTrailer = nil
                end

                if GetEntitySpeed(vehicle) <= maxSpeed and GetGameTimer() - lastDetachTime > detachCooldown then
                    local trailer = findTrailerNear(vehicle, hitchCoords)
                    if trailer then
                        AttachVehicleToTrailer(vehicle, trailer, 2.0)
                    end
                end
            end
        end

        Wait(sleep)
    end
end)
