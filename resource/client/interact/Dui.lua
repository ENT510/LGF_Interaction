local shared = lib.load('resource.utils.shared')
local Dui = {}
local activeInteractions = {}
local interactionCounter = 0
local resource = cache.resource or GetCurrentResourceName()
local Url = ('nui://%s/web/build/index.html'):format(resource)
local screenWidth, screenHeight = GetActiveScreenResolution()
local playerPed, playerCoords

local keybindScrollUp = lib.addKeybind({
    name = 'interaction_scroll_up',
    description = 'Scroll Up Interaction',
    defaultKey = 'UP',
    onPressed = function()
        Dui.handleScroll('up')
    end,
})

local keybindScrollDown = lib.addKeybind({
    name = 'interaction_scroll_down',
    description = 'Scroll Down Interaction',
    defaultKey = 'DOWN',
    onPressed = function()
        Dui.handleScroll('down')
    end,
})

local keybindSelect = lib.addKeybind({
    name = 'interaction_select',
    description = 'Select Interaction Option',
    defaultKey = 'RETURN',
    onPressed = function()
        Dui.handleSelect()
    end,
})

function Dui.handleScroll(direction)
    for _, interaction in pairs(activeInteractions) do
        if interaction.interactionOpened then
            if direction == 'up' then
                interaction.CurrentItem = (interaction.CurrentItem > 1) and (interaction.CurrentItem - 1) or #interaction.BindCached
                interaction.DuiObject:sendMessage({ action = 'updateIndex', data = { direction = 'up' } })
            elseif direction == 'down' then
                interaction.CurrentItem = (interaction.CurrentItem < #interaction.BindCached) and (interaction.CurrentItem + 1) or 1
                interaction.DuiObject:sendMessage({ action = 'updateIndex', data = { direction = 'down' } })
            end
        end
    end
end

function Dui.handleSelect()
    for _, interaction in pairs(activeInteractions) do
        if interaction.interactionOpened then
            local selectedItem = interaction.BindCached[interaction.CurrentItem]
            local closestDistance = math.huge

            for _, coords in ipairs(interaction.coordsList) do
                local FormattedCoords = vec3(coords.x, coords.y, coords.z)
                local distance = #(playerCoords - FormattedCoords)
                closestDistance = math.min(closestDistance, distance)
                if selectedItem.canInteract and not selectedItem.canInteract(closestDistance, interaction.id, interaction.myPed) then
                    Shared.debugData('WARNING', 'Interaction blocked due to canInteract check failure.')
                    return false
                end
            end


            if selectedItem.RequestedItem then
                local itemName = selectedItem.RequestedItem.ItemName
                local itemCount = selectedItem.RequestedItem.ItemCount or 1
                local playerHasItem = lib.callback.await('LGF_Interaction.getItemCount', false, itemName, itemCount)
                if playerHasItem then
                    if selectedItem.onClick then
                        Shared.debugData('INFO', ('Requirement met for %s. Triggering action.'):format(itemName))
                        selectedItem.onClick(interaction)
                    end
                else
                    Shared.debugData('WARNING', ('You need at least %d of %s to perform this action.'):format(itemCount, itemName))
                end
            elseif selectedItem.onClick then
                Shared.debugData('INFO', ('No item requirement specified. Triggering action for %s.'):format(selectedItem.title))
                selectedItem.onClick(interaction)
            end
        end
    end

    return true
end

function Dui.draw3DSprite(coords, dictName, txtName, maxDistance)
    local distance = #(playerCoords - coords)
    if distance > maxDistance then return end

    local camMode, scale = GetFollowPedCamViewMode(), math.max(0.1, math.min(1.5, 1.5 / distance))
    local zOffset = (camMode == 0 or camMode == 1 or camMode == 2) and 0.7 or (camMode == 3 and 0.4 or 0)

    if camMode == 3 then scale = scale * 1.2 end
    if camMode >= 1 and camMode <= 3 then zOffset = zOffset + 0.8 end

    SetDrawOrigin(coords.x, coords.y, coords.z + zOffset, 0)
    DrawInteractiveSprite(dictName, txtName, 0, 0, scale, scale, 0.0, 255, 255, 255, 255)
    ClearDrawOrigin()
end

function Dui.createInteraction(data)
    if not data or not data.DataBind then
        warn("createInteraction: Missing required fields (DataBind).")
        return
    end


    local randomID = shared.randomID()
    local interactionID = ('%s_%d_%s'):format(resource, interactionCounter, randomID)
    interactionCounter = interactionCounter + 1


    local finalCoords = data.Coords

    if data.OffsetCoords then finalCoords = finalCoords + data.OffsetCoords end

    local interaction = {
        id = interactionID,
        data = data,
        CurrentItem = 1,
        BindCached = data.DataBind,
        interactionOpened = false,
        visible = true,
        DuiObject = lib.dui:new({ url = Url, width = screenWidth, height = screenHeight, debug = false }),
        distance = data.distance or 15,
        closest = data.closest or 5.0,
        hasEntered = false,
        onEnter = data.onEnter,
        onExit = data.onExit,
        nearby = data.nearby,
        caninteract = data.canInteract,
        coordsList = type(finalCoords) == 'table' and finalCoords or { finalCoords },
        model = data.Model,
        debug = data.debug or false,
        debugColour = (data.debugColour and next(data.debugColour)) and data.debugColour or { r = 128, g = 0, b = 128, a = 100 },
        myPed = playerPed
    }

    activeInteractions[interactionID] = interaction

    Citizen.SetTimeout(500, function()
        local sanitizedDataBind = {}
        for i = 1, #data.DataBind do
            local item = data.DataBind[i]
            sanitizedDataBind[#sanitizedDataBind + 1] = {
                index = item.index,
                title = item.title,
                icon = item.icon,
                description = item.description,
                image = item.image,
                buttonColor = item.buttonColor,
                entity = item.entity,
                requestedItem = item.RequestedItem,
            }
        end
        interaction.DuiObject:sendMessage({
            action = 'openInteraction',
            data = {
                Visible = interaction.visible,
                DataBind = sanitizedDataBind
            }
        })
    end)

    return interactionID
end

-- function Dui.SetInteractionVisible(interactionID, isVisible)
--     local interaction = activeInteractions[interactionID]
--     if interaction then
--         interaction.visible = isVisible
--         interaction.DuiObject:sendMessage({ action = 'setVisible', data = { Visible = interaction.visible } })
--     end
-- end

function Dui.removeInteraction(interactionID)
    local interaction = activeInteractions[interactionID]
    if interaction then
        interaction.interactionOpened = false
        interaction.CurrentItem = 1
        if interaction.DuiObject then
            interaction.DuiObject:remove()
            interaction.DuiObject = nil
        end
        activeInteractions[interactionID] = nil
    end
end

function Dui.debugDrawSphere(self)
    if not self.coordsList or (type(self.coordsList) ~= "table" and #self.coordsList == 0) then return end
    if type(self.coordsList) ~= "table" then self.coordsList = { self.coordsList } end

    for _, coord in ipairs(self.coordsList) do
        if coord and coord.x and coord.y and coord.z then
            DrawMarker(28, coord.x, coord.y, coord.z,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                self.closest, self.closest, self.closest,
                self.debugColour.r, self.debugColour.g, self.debugColour.b, self.debugColour.a,
                false, false, 0, false, false, false, false)
        end
    end
end

CreateThread(function()
    while true do
        playerPed = PlayerPedId()
        playerCoords = GetEntityCoords(playerPed)
        local sleep = 750

        for _, interaction in pairs(activeInteractions) do
            local closestDistance = math.huge
            for _, coords in ipairs(interaction.coordsList) do
                local FormattedCoords = vec3(coords.x, coords.y, coords.z)
                local distance = #(playerCoords - FormattedCoords)
                if distance <= interaction.distance then
                    if interaction.visible then
                        sleep = 0
                        Dui.draw3DSprite(FormattedCoords, interaction.DuiObject.dictName, interaction.DuiObject.txtName, interaction.distance)
                    end
                    if interaction.debug then
                        Dui.debugDrawSphere(interaction)
                    end
                end
                closestDistance = math.min(closestDistance, distance)
            end

            if closestDistance <= interaction.closest then
                if not interaction.hasEntered then
                    interaction.hasEntered = true
                    interaction.interactionOpened = true
                    if interaction.onEnter then interaction.onEnter(interaction) end
                end
                if interaction.nearby then interaction.nearby(interaction) end
            else
                if interaction.hasEntered then
                    interaction.hasEntered = false
                    interaction.interactionOpened = false
                    if interaction.onExit then interaction.onExit(interaction) end
                end
            end
        end
        Wait(sleep)
    end
end)


exports('addInteraction', Dui.createInteraction)
exports('removeInteraction', Dui.removeInteraction)

return Dui
