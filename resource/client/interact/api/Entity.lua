local entityArray = {}

local function getEntityBoneCoords(entity, boneName)
    local boneIndex = GetEntityBoneIndexByName(entity, boneName)
    if boneIndex == -1 then
        print(("Entity bone %s not found"):format(boneName))
        return nil
    end
    local boneCoords = GetWorldPositionOfEntityBone(entity, boneIndex)
    return boneCoords
end

local function addInteractionEntity(data)
    assert(data and data.netID, "addInteractionEntity: Missing netID in data.")
    assert(data and data.dataBind, "addInteractionEntity: Missing dataBind in data.")

    local entity = NetworkGetEntityFromNetworkId(data.netID)

    repeat Wait(100) until NetworkDoesEntityExistWithNetworkId(data.netID)

    if not DoesEntityExist(entity) then
        warn("entity is not Networked")
        return
    end

    local coords = GetEntityCoords(entity)


    if data.entityBone then
        local boneCoords = getEntityBoneCoords(entity, data.entityBone)
        if boneCoords then coords = boneCoords else coords = vector3(coords.x, coords.y, coords.z + 1.0) end
    end

    local model = GetEntityModel(entity)
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
        entity = entity,
        debugColour = debugColour,
        model = model,
        netID = data.netID,

        onEnter = function(self)
            if data.onEnter then
                self.entity = self.data.entity
                self.netID = self.data.netID
                self.model = self.data.model
                data.onEnter(self)
            end
        end,


        onExit = function(self)
            if data.onExit then
                data.onExit(self)
            end
        end,

        nearby = function(self)
            if data.nearby then
                data.nearby(self)
            end
        end,
    }, GetInvokingResource())


    entityArray[data.netID] = entityArray[data.netID] or {}
    entityArray[data.netID].interactionID = interactionID

    return interactionID
end

local function removeInteractionEntity(netID)
    if entityArray[netID] and entityArray[netID].interactionID then
        Dui.removeInteraction(entityArray[netID].interactionID)
        entityArray[netID].interactionID = nil
    else
        print(("No interaction found for the entity with netID: %s"):format(netID))
    end
end


local function getAllInteractionEntities()
    return entityArray
end



exports('addInteractionEntity', addInteractionEntity)
exports('removeInteractionEntity', removeInteractionEntity)
exports('getInteractionEntities', getAllInteractionEntities)

return addInteractionEntity
