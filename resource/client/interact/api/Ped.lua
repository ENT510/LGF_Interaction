local Dui = lib.load("resource.client.interact.Dui")
local pedArray = {}

local function createPed(position, model, pedID)
    if pedArray[pedID] and pedArray[pedID].ped then return pedArray[pedID].ped end
    local modelLoaded = lib.requestModel(model)
    if not modelLoaded then return nil end
    local ped = CreatePed(0, modelLoaded, position.x, position.y, position.z - 1, position.w, false, true)
    SetModelAsNoLongerNeeded(modelLoaded)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCanUseAutoConversationLookat(ped, false)
    ClearPedTasksImmediately(ped)
    pedArray[pedID] = { ped = ped, position = position, model = model }
    return ped
end

local function removeInteractionPed(pedID, interactionID)
    local pedData = pedArray[pedID]
    if pedData then
        if interactionID then
            Dui.removeInteraction(interactionID)
        end
        DeleteEntity(pedData.ped)
        pedArray[pedID] = nil
    else
        print(("Ped with ID %s not found"):format(pedID))
    end
end

local function removePed(pedID)
    local pedData = pedArray[pedID]
    if pedData then
        DeleteEntity(pedData.ped)
        pedArray[pedID] = nil
    else
        print(("Ped with ID %s not found"):format(pedID))
    end
end

local function addInteractionPed(data)
    assert(data and data.Coords, "addInteractionPed: Missing position in data.")
    assert(data and data.model, "addInteractionPed: Missing model in data.")
    assert(data and data.pedID, "addInteractionPed: Missing pedID in data.")
    assert(data and data.dataBind, "addInteractionPed: Missing dataBind in data.")

    local ped = createPed(data.Coords, data.model, data.pedID)
    local coords = vec4(data.Coords.x, data.Coords.y, data.Coords.z + 1, data.Coords.w)


    local distance = data.distance or 10
    local closest = data.closest or 5.0
    local visible = true
    local debug = data.debug or false
    local debugColour = data.debugColour or { r = 128, g = 0, b = 128, a = 100 }

    local interactionID = Dui.createInteraction({
        distance = distance,
        closest = closest,
        visible = visible,
        Coords = coords,
        debug = debug,
        DataBind = data.dataBind,
        pedID = data.pedID,
        debugColour = debugColour,
        model = data.model,
        ped = ped,

        onEnter = function(self)
            if data.onEnter then
                if not self.pedEntity then self.pedEntity = createPed(data.Coords, data.model, data.pedID) end
                self.pedID = data.pedID
                data.onEnter(self)
            end
        end,

        onExit = function(self)
            if data.onExit then
                data.onExit(self)
                if self.pedEntity then
                    removePed(data.pedID)
                    self.pedEntity = nil
                end
            end
        end,

        nearby = function(self) if data.nearby then data.nearby(self) end end,
    })


    pedArray[data.pedID].interactionID = interactionID

    return interactionID
end

local function getAllInteractionPeds()
    return pedArray
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for pedID, pedData in pairs(pedArray) do
            removeInteractionPed(pedID)
        end
        pedArray = {}
    end
end)

exports('addInteractionPed', addInteractionPed)
exports('removeInteractionPed', removeInteractionPed)
exports('removePed', removePed)
exports('getInteractionPeds', getAllInteractionPeds)

return addInteractionPed


