lib.callback.register("LGF_Interaction.getItemCount", function(source, itemName, count)
    if not source or not itemName then return end
    return Server.hasItem(source, itemName, count)
end)
