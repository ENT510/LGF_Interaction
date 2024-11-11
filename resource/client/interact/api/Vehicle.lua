local vehicleArray = {}


local function getVehicleBoneCoords(vehicle, boneName)
    local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
    if boneIndex == -1 then print(("Vehicle bone %s not found"):format(boneName)) return nil end
    local boneCoords = GetWorldPositionOfEntityBone(vehicle, boneIndex)
    local adjustedBoneCoords = vector3(boneCoords.x, boneCoords.y, boneCoords.z + 0.5)
    return adjustedBoneCoords
end


local function getFirstAvailableBoneCoords(vehicle, bones)
    if type(bones) == "table" then
        for _, boneName in ipairs(bones) do
            local boneCoords = getVehicleBoneCoords(vehicle, boneName)
            if boneCoords then
                return boneCoords
            end
        end
    else
        return getVehicleBoneCoords(vehicle, bones)
    end
    return nil
end


local function addInteractionVehicle(data)
    assert(data and data.vehicle, "addInteractionVehicle: Missing vehicle in data.")
    assert(data and data.dataBind, "addInteractionVehicle: Missing dataBind in data.")
    repeat Wait(100) until DoesEntityExist(data.vehicle)
    local coords = GetEntityCoords(data.vehicle)

    if data.vehicleBone then
        local boneCoords = getFirstAvailableBoneCoords(data.vehicle, data.vehicleBone)
        if boneCoords then
            coords = boneCoords
        else
            coords = vec3(coords.x, coords.y, coords.z + 1.0)
        end
    end

    local model = GetEntityModel(data.vehicle)
    local vehicleID = data.vehicle
    local netID = NetworkGetNetworkIdFromEntity(vehicleID)

    while not (NetworkDoesEntityExistWithNetworkId(netID) or netID == 0) do Wait(1) end

    local distance = data.distance or 10
    local closest = data.closest or 5.0
    local visible = true
    local debug = data.debug or false
    local debugColour = data.debugColour or { r = 128, g = 0, b = 128, a = 100 }

    local interactionID = Dui.createInteraction({
        distance = distance,
        closest = closest,
        visible = visible,
        Coords = vec4(coords.x, coords.y, coords.z, 0),
        debug = debug,
        DataBind = data.dataBind,
        entity = vehicleID,
        debugColour = debugColour,
        model = model,
        netID = netID,
        onEnter = function(self)
            if data.onEnter then
                self.vehicle = self.data.entity
                self.netID = self.data.netID
                self.vehicleModel = self.data.model
                data.onEnter(self)
                self.data.vehicleID = nil
                self.data.netID = nil
                self.data.model = nil
            end
        end,

        onExit = function(self)
            if data.onExit then
                data.onExit(self)
            end
        end,

        nearby = function(interactionID)
            if data.nearby then
                data.nearby(interactionID)
            end
        end,
    }, GetInvokingResource())

    vehicleArray[vehicleID] = vehicleArray[vehicleID] or {}
    vehicleArray[vehicleID].interactionID = interactionID

    return interactionID
end


local function removeInteractionVehicle(vehicle)
    local vehicleID = vehicle
    if vehicleArray[vehicleID] and vehicleArray[vehicleID].interactionID then
        Dui.removeInteraction(vehicleArray[vehicleID].interactionID)
        vehicleArray[vehicleID].interactionID = nil
    else
        print(("No interaction found for the vehicle with ID: %s"):format(vehicleID))
    end
end


local function getAllInteractionVehicles()
    return vehicleArray
end


exports('addInteractionVehicle', addInteractionVehicle)
exports('removeInteractionVehicle', removeInteractionVehicle)
exports('getInteractionVehicles', getAllInteractionVehicles)

return addInteractionVehicle
