--- Checks if the player has a specific item and quantity
---@param source number The player's source ID
---@param itemName string The name of the item to check
---@param count number|nil The quantity of the item to check (optional)
---@return boolean Whether the player has the item in the specified quantity
lib.callback.register("LGF_Interaction.getItemCount", function(source, itemName, count)
    if not source or not itemName then return end
    return Server.hasItem(source, itemName, count)
end)

--- Handles various item actions such as 'get', 'has', 'give', and 'remove'
---@param source number The player's source ID
---@param action string The action to perform ('get', 'has', 'give', 'remove')
---@param itemName string The name of the item for the action
---@param count number|nil The quantity of the item for the action (optional)
---@return boolean success Whether the action was successful
---@return table|nil errorData Error details if the action fails
lib.callback.register('lgf:interaction:itemAction', function(source, action, itemName, count)
    -- Check for essential parameters
    if not source or not itemName then
        -- Return structured error if essential parameters are missing
        return false, {
            code = 'missing_required_params',
            message = 'The source or itemName parameter is missing',
        }
    end

    -- Handle different actions
    if action == 'get' then
        return true, Server.getItemCount(source, itemName)
    elseif action == 'has' then
        return true, Server.hasItem(source, itemName, count)
    elseif action == 'give' then
        local success, err = Server.giveItem(source, itemName, count)
        if not success then
            -- Log error without interruption if the action is recoverable
            print(('Error adding item: %s'):format(err))
            return false, {
                code = 'give_item_failed',
                message = 'Failed to add the item',
                details = err,
            }
        end
        return true
    elseif action == 'remove' then
        local success, err = Server.removeItem(source, itemName, count)
        if not success then
            -- Log error without interruption if the action is recoverable
            print(('Error removing item: %s'):format(err))
            return false, {
                code = 'remove_item_failed',
                message = 'Failed to remove the item',
                details = err,
            }
        end
        return true
    else
        -- Return structured error if action is unknown
        return false, {
            code = 'unknown_action',
            message = ('Unknown action: %s'):format(action),
        }
    end
end)
