Dui = {}

local shared = lib.load('resource.utils.shared')

local activeInteractions = {}
local interactionCounter = 0
local resource = cache.resource or GetCurrentResourceName()
local Url = ('nui://%s/web/build/index.html'):format(resource)
local screenWidth, screenHeight = GetActiveScreenResolution()
local playerPed, playerCoords
local totalInteractions = 0
local loadedInteractions = 0

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
                interaction.CurrentItem = (interaction.CurrentItem > 1) and (interaction.CurrentItem - 1) or
                    #interaction.BindCached
                interaction.DuiObject:sendMessage({ action = 'updateIndex', data = { direction = 'up' } })
            elseif direction == 'down' then
                interaction.CurrentItem = (interaction.CurrentItem < #interaction.BindCached) and
                    (interaction.CurrentItem + 1) or 1
                interaction.DuiObject:sendMessage({ action = 'updateIndex', data = { direction = 'down' } })
            end
        end
    end
end

function Dui.handleSelect()
    for _, interaction in pairs(activeInteractions) do
        if interaction and interaction.interactionOpened then

            local currentItem = interaction.BindCached and interaction.BindCached[interaction.CurrentItem]
            if currentItem then
                local closestDistance = math.huge
                for _, coords in ipairs(interaction.coordsList) do
                    local FormattedCoords = vec3(coords.x, coords.y, coords.z)
                    local distance = #(playerCoords - FormattedCoords)
                    closestDistance = math.min(closestDistance, distance)

                    if currentItem.canInteract and not currentItem.canInteract(closestDistance, interaction.id, interaction.myPed, EntityVehicle) then
                        Shared.debugData('WARNING', 'Interaction blocked due to canInteract check failure.')
                        return false
                    end
                end

                if currentItem.RequestedItem then
                    local itemName = currentItem.RequestedItem.ItemName
                    local itemCount = currentItem.RequestedItem.ItemCount or 1
                    local playerHasItem = lib.callback.await('LGF_Interaction.getItemCount', false, itemName, itemCount)
                    if playerHasItem then
                        if currentItem.onClick then
                            Shared.debugData('INFO', ('Requirement met for %s. Triggering action.'):format(itemName))
                            currentItem.onClick(interaction)
                        end
                    else
                        Shared.debugData('WARNING', ('You need at least %d of %s to perform this action.'):format(itemCount, itemName))
                    end
                elseif currentItem.onClick then
                    Shared.debugData('INFO', ('No item requirement specified. Triggering action for %s.'):format(currentItem.title))
                    currentItem.onClick(interaction)
                end
            else
                Shared.debugData('ERROR', 'Invalid item selected in interaction.')
            end
        end
    end
end

local isOriginSet = false

function Dui.draw3DSprite(coords, dictName, txtName, maxDistance)
    local distance = #(playerCoords - coords)
    if distance > maxDistance then return end

    local scale = math.max(0.1, 1.5 / distance)
    scale = math.min(scale, 1.0)

    local camMode = GetFollowPedCamViewMode()
    local zOffset = 0.7
    if camMode == 1 then
        zOffset = zOffset + 0.5
    elseif camMode == 2 then
        zOffset = zOffset + 1.3
    elseif camMode == 3 then
        zOffset = zOffset + 0.6
    end

    if not isOriginSet then
        SetDrawOrigin(coords.x, coords.y, coords.z + zOffset, false)
        isOriginSet = true
    end

    DrawInteractiveSprite(dictName, txtName, 0, 0, scale, scale, 0.0, 255, 255, 255, 255)

    if isOriginSet then
        ClearDrawOrigin()
        isOriginSet = false
    end
end

local function checkTimeout(interaction, startTime, timeoutDuration)
    local elapsedTime = GetGameTimer() - startTime
    if elapsedTime > timeoutDuration then
        warn(("Timeout: Failed to create DuiObject for interaction %s"):format(interaction.id))
        activeInteractions[interaction.id] = nil
        return true
    end
    return false
end



function Dui.createInteraction(data, invoker)
    local invoker = invoker

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
        Resource = invoker,
        interactionOpened = false,
        visible = true,
        DuiObject = nil,
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
        debugColour = data.debugColour or { r = 128, g = 0, b = 128, a = 100 },
        myPed = playerPed
    }

    totalInteractions = totalInteractions + 1
    activeInteractions[interactionID] = interaction


    interaction.DuiObject = lib.dui:new({ url = Url, width = screenWidth, height = screenHeight, debug = false })

    while interaction.DuiObject == nil do
        if checkTimeout(interaction, GetGameTimer(), 5000) then return nil end
        Wait(100)
    end
    loadedInteractions = loadedInteractions + 1
    Wait(1000)

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
        if interaction.DuiObject and interaction.DuiObject.duiHandle then
            interaction.DuiObject:remove()
            interaction.DuiObject = nil
        end
        activeInteractions[interactionID] = nil
    end
end

function Dui.debugDrawSphere(self)
    local Closest = self.closest
    if not self.coordsList or (type(self.coordsList) ~= "table" and #self.coordsList == 0) then return end
    if type(self.coordsList) ~= "table" then self.coordsList = { self.coordsList } end

    local debugColour = self.debugColour

    for _, coord in ipairs(self.coordsList) do
        if coord and coord.x and coord.y and coord.z then
            local isVehicle = self.vehicle and IsEntityAVehicle(self.vehicle)
            local distanceToVehicle = #(playerCoords - vec3(coord.x, coord.y, coord.z))

            if not isVehicle then
                DrawMarker(28, coord.x, coord.y, coord.z,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    Closest, Closest, Closest,
                    debugColour.r, debugColour.g, debugColour.b, debugColour.a,
                    false, false, 0, false, false, false, false)
            else
                if distanceToVehicle <= Closest then
                    SetEntityDrawOutline(self.vehicle, true)
                    SetEntityDrawOutlineColor(debugColour.r, debugColour.g, debugColour.b, debugColour.a)
                    SetEntityDrawOutlineShader(0)
                else
                    SetEntityDrawOutline(self.vehicle, false)
                end
            end
        end
    end
end

CreateThread(function()
    while true do
        playerPed = PlayerPedId()
        playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000

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
                if interaction.nearby then interaction.nearby(interaction.id) end
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

-- return Dui
