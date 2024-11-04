local activeInteractions = {}

--- @param data table -- Configuration data for creating interactions
--- @param data.DataBind table -- Data binding for interaction options
--- @param data.Model table -- Model identifiers to create interactions for
--- @param data.Distance number -- Distance within which interactions are available (default is 4.0)
--- @param data.OffsetCoords vec3 -- Offset coordinates for interaction positioning
function Dui.createInteractionGlobalModel(data)
    print(json.encode(data, { indent = true }))

    if not data.DataBind or not data.Model then
        Shared.debugData("WARNING", "createInteractionGlobalModel: No DataBind or Model provided.")
        return nil
    end

    Dui.clearAllInteractionsModel()

    local interactionDistance = data.Distance or 4.0
    local offsetCoords = data.OffsetCoords or vec3(0, 0, 0)

    local lastCreatedInteractionID = nil
    SetTimeout(100, function()
        CreateThread(function()
            while true do
                Wait(2000)

                local playerCoords = GetEntityCoords(GetPlayerPed(PlayerId()))
                local allModels = GetAllModels(data.Model)
                local currentInteractions = {}

                for _, modelInfo in pairs(allModels) do
                    local modelID = modelInfo.model
                    local modelCoords = modelInfo.coords
                    local distanceToModel = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, modelCoords.x, modelCoords.y, modelCoords.z)

                    if distanceToModel <= interactionDistance then
                        local interactionCoords = vec3(
                            modelCoords.x + offsetCoords.x,
                            modelCoords.y + offsetCoords.y,
                            modelCoords.z + offsetCoords.z
                        )

                        local interactionKey = ("%s_%s"):format(tostring(modelID), tostring(modelCoords))

                        local model = modelInfo.entity or nil
                        if not activeInteractions[interactionKey] then
                            local modelSpecificDataBind = {}
                            for _, item in ipairs(data.DataBind) do
                                local clonedItem = {
                                    index = item.index,
                                    title = item.title,
                                    icon = item.icon,
                                    description = item.description,
                                    image = item.image,
                                    buttonColor = item.buttonColor,
                                    RequestedItem = item.RequestedItem,
                                    onClick = function(index)
                                        item.onClick(index, model, modelInfo.coords)
                                    end
                                }
                                table.insert(modelSpecificDataBind, clonedItem)
                            end

                            local interaction = Dui.CreateInteraction({
                                Coords = interactionCoords,
                                Visible = true,
                                DataBind = modelSpecificDataBind
                            })

                            if interaction then
                                lastCreatedInteractionID = interaction
                            end

                            Shared.debugData("INFO", ("Created interaction for model ID %s within distance %.2f"):format(modelID, distanceToModel))
                            activeInteractions[interactionKey] = interaction
                        end

                        currentInteractions[interactionKey] = true
                    end
                end


                for interactionKey, interaction in pairs(activeInteractions) do
                    if not currentInteractions[interactionKey] then
                        Dui.removeInteractionById(interaction)
                        Shared.debugData("DEBUG", ("Closed inactive interaction for key: %s"):format(interactionKey))
                        activeInteractions[interactionKey] = nil
                    end
                end
            end
        end)
    end)

    return lastCreatedInteractionID
end

--- @param modelToCheck table -- A table of model identifiers to check against
--- @return table -- A list of models with their coordinates and entities
function GetAllModels(modelToCheck)
    local models = {}
    local AllObj = GetGamePool("CObject")

    for i = 1, #AllObj do
        local entity = AllObj[i]
        local model = GetEntityModel(entity)

        if modelToCheck[model] then
            local coords = GetEntityCoords(entity)
            models[#models + 1] = {
                coords = coords,
                entity = entity,
                model = model
            }
        end
    end
    return models
end

exports('createInteractionGlobalModel', function(data)
    local interactionID = Dui.createInteractionGlobalModel(data)
    return interactionID
end)


function Dui.clearAllInteractionsModel()
    for interactionKey, interaction in pairs(activeInteractions) do
        Dui.removeInteractionById(interaction)
        Shared.debugData("DEBUG", ("Cleared interaction for key: %s"):format(interactionKey))
    end
    activeInteractions = {}
end

exports('clearAllInteractionsModel', function()
    Dui.clearAllInteractionsModel()
end)
