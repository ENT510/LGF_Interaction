Server = {}

function Server.hasItem(target, itemName, count)
    if GetResourceState("ox_inventory"):find("start") then
        local itemCount = exports.ox_inventory:GetItemCount(target, itemName)
        return itemCount
    end
    return false
end
