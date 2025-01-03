-- Server = {}

-- function Server.hasItem(target, itemName, count)
--     if GetResourceState("ox_inventory"):find("start") then
--         local itemCount = exports.ox_inventory:GetItemCount(target, itemName)
--         return itemCount
--     end
--     return false
-- end

Server = {}

--- Checks if the player has a specific item in their inventory
---@param target number The player source ID
---@param itemName string The name of the item to check
---@param count number|nil The quantity of the item required (optional)
---@return boolean|number Returns the count of the item if found, false otherwise
function Server.hasItem(target, itemName, count)
    if GetResourceState("ox_inventory"):find("start") then
        local itemCount = exports.ox_inventory:GetItemCount(target, itemName)
        if count then
            return itemCount >= count
        end
        return itemCount
    end
    return false
end

--- Adds a specified item to the player's inventory
---@param target number The player source ID
---@param itemName string The name of the item to add
---@param count number The quantity of the item to add
---@return boolean success Whether the item was successfully added
---@return string? errorMessage Optional error message if the addition fails
function Server.giveItem(target, itemName, count)
    if GetResourceState("ox_inventory"):find("start") then
        local success, response = exports.ox_inventory:AddItem(target, itemName, count)
        if success then
            return true
        else
            return false, response or "unknown_error"
        end
    end
    return false, "ox_inventory_not_started"
end

--- Removes a specified item from the player's inventory
---@param target number The player source ID
---@param itemName string The name of the item to remove
---@param count number The quantity of the item to remove
---@return boolean success Whether the item was successfully removed
---@return string? errorMessage Optional error message if the removal fails
function Server.removeItem(target, itemName, count)
    if GetResourceState("ox_inventory"):find("start") then
        local success, response = exports.ox_inventory:RemoveItem(target, itemName, count)
        if success then
            return true
        else
            return false, response or "unknown_error"
        end
    end
    return false, "ox_inventory_not_started"
end

--- Checks if the player can carry a specific quantity of an item
---@param target number The player source ID
---@param itemName string The name of the item to check
---@param count number The quantity of the item
---@return boolean Whether the player can carry the specified quantity of the item
function Server.canCarryItem(target, itemName, count)
    if GetResourceState("ox_inventory"):find("start") then
        return exports.ox_inventory:CanCarryItem(target, itemName, count)
    end
    return false
end
