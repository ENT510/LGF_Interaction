local SetDrawOrigin                 = SetDrawOrigin
local DrawInteractiveSprite         = DrawInteractiveSprite
local ClearDrawOrigin               = ClearDrawOrigin
local IsControlJustPressed          = IsControlJustPressed
local GetCurrentResourceName        = GetCurrentResourceName
local GetActiveScreenResolution     = GetActiveScreenResolution
local GetResourceState              = GetResourceState

Dui                                 = {}
LocalPlayer.state.interactionOpened = false
_DEBUG                              = false

local screenWidth, screenHeight     = GetActiveScreenResolution()
local activeInteractions            = {}
local interactionCounter            = 0
local DuiObject                     = nil
local CurrentItem                   = 1
local hasUtility                    = GetResourceState("LGF_Utility"):find("start") and true or false
local Url                           = ("nui://%s/web/build/index.html"):format(GetCurrentResourceName())



function Dui.loadDui()
    if not DuiObject then
        DuiObject = lib.dui:new({
            url = Url,
            width = screenWidth,
            height = screenHeight,
            debug = _DEBUG
        })
    end
end

function Dui.drawSprite(coords, dictName, txtName)
    SetDrawOrigin(coords.x, coords.y, coords.z + 1)
    DrawInteractiveSprite(dictName, txtName, 0, 0, 1, 1, 0.0, 255, 255, 255, 255)
    ClearDrawOrigin()
end

function Dui.clearDui()
    if DuiObject then
        if DuiObject.remove then
            DuiObject:remove()
        else
            print("Warning: DuiObject does not have a 'remove' method.")
        end
        DuiObject = nil
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    Dui.clearDui()
end)

RegisterNetEvent('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    Dui.loadDui()
end)

---@param data table
function Dui.CreateInteraction(data)
    -- if type(data) ~= "table" or not data.Coords or not data.DataBind then
    --     Shared.printTypeError("table with 'Coords' and 'DataBind'", type(data), "Dui.CreateInteraction")
    --     return
    -- end

    if data.Visible and LocalPlayer.state.interactionOpened then return end

    Dui.loadDui()
    LocalPlayer.state.interactionOpened = data.Visible
    BindCached = data.DataBind
    CurrentItem = 1

    Citizen.SetTimeout(500, function()
        local sanitizedDataBind = {}

        for _, item in ipairs(data.DataBind) do
            local clonedItem = {
                index = item.index,
                title = item.title,
                icon = item.icon,
                description = item.description,
                image = item.image,
                buttonColor = item.buttonColor,
                entity = item.entity,
                requstedItem = item.RequestedItem,
            }
            table.insert(sanitizedDataBind, clonedItem)
        end

        DuiObject:sendMessage({
            action = "openInteraction",
            data = {
                Visible = data.Visible,
                DataBind = sanitizedDataBind
            }
        })

        if data.Visible then
            Citizen.CreateThread(function()
                while LocalPlayer.state.interactionOpened do
                    Wait(1)

                    if IsControlJustPressed(0, 172) then
                        CurrentItem = (CurrentItem > 1) and (CurrentItem - 1) or #data.DataBind
                        DuiObject:sendMessage({
                            action = "updateIndex",
                            data = {
                                direction = "up"
                            }
                        })
                    elseif IsControlJustPressed(0, 173) then
                        CurrentItem = (CurrentItem < #data.DataBind) and (CurrentItem + 1) or 1
                        DuiObject:sendMessage({
                            action = "updateIndex",
                            data = {
                                direction = "down"
                            }
                        })
                    elseif IsControlJustPressed(0, 191) then
                        local selectedItem = BindCached[CurrentItem]

                        if selectedItem.RequestedItem then
                            local itemName = selectedItem.RequestedItem.ItemName
                            local itemCount = selectedItem.RequestedItem.ItemCount or 1

                            local playerItemCount = lib.callback.await("LGF_Interaction.getItemCount", false, itemName, itemCount)

                            if type(playerItemCount) == "number" then
                                if playerItemCount >= itemCount then
                                    if selectedItem.onClick then
                                        Shared.debugData("INFO", ("Requirement met for %s (%d items). Triggering action."):format(itemName, playerItemCount))
                                        selectedItem.onClick(CurrentItem, selectedItem.entity, data.Coords)
                                    end
                                else
                                    Shared.debugData("WARNING", ("You need at least %d of %s to perform this action."):format(itemCount, itemName))
                                end
                            end
                        else
                            if selectedItem.onClick then
                                Shared.debugData("INFO", ("No item requirement specified. Triggering action for %s."):format(selectedItem.title))

                                selectedItem.onClick(CurrentItem, data.Coords)
                            end
                        end
                    end

                    Dui.drawSprite(data.Coords, DuiObject?.dictName, DuiObject?.txtName)
                end
            end)
        end
    end)

    local randomID = nil

    if hasUtility then randomID = LGF.string:RandStr(6, 'upp') else randomID = math.random(100000, 999999) end

    local interactionID = ("%s_%d_%s"):format(GetCurrentResourceName(), interactionCounter, randomID)
    interactionCounter = interactionCounter + 1
    activeInteractions[interactionID] = data

    return interactionID
end

function Dui.CloseInteraction()
    local State = false

    LocalPlayer.state.interactionOpened = State
    CurrentItem = 1
    DuiObject:sendMessage({
        action = "openInteraction",
        data = {
            Visible = false,
            DataBind = {}
        }
    })
end

---@param data table -- Data used to create the interaction
exports('createInteraction', function(data)
    return Dui.CreateInteraction({
        Coords = data.Coords,
        Visible = true,
        DataBind = data.DataBind
    })
end)

exports('closeInteraction', function()
    return Dui.CloseInteraction()
end)

---@param interactionID string -- The ID of the interaction to remove
function Dui.removeInteractionById(interactionID)
    if activeInteractions[interactionID] then
        local success, err = pcall(function()
            Dui.CloseInteraction()
        end)

        if not success then
            Shared.debugData("ERROR", ("during CloseInteraction: %s"):format(err))
        else
            activeInteractions[interactionID] = nil
            Shared.debugData("INFO", ("Interaction with ID: %s removed successfully."):format(interactionID))
        end
    else
        warn(("No interaction found for ID: %s"):format(interactionID))
    end
end

--- Remove Interaction for Specific ID
---@param interactionID string -- ID of the interaction to be removed
exports('removeInteractionById', function(interactionID)
    return Dui.removeInteractionById(interactionID)
end)

--- Get interaction by ID
---@param interactionID string
function Dui.getInteractionById(interactionID)
    return activeInteractions[interactionID] or nil
end

exports('getInteractionById', function(interactionID)
    return Dui.getInteractionById(interactionID)
end)
