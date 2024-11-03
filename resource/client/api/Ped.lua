--- @param data table -- Interaction data for the entity
--- @param data.Entity any -- The entity (ped) to interact with
--- @param data.IndexBone number -- The index of the bone to get the coordinates from
--- @param data.OffsetBone vec3 -- Offset along the X, Y, and Z axes
--- @param data.DataBind table -- The data bindings for interaction options
function Dui.createInteractionPed(data)
    if not data or not data.Entity or not data.DataBind then
        warn("createInteractionPed: Missing required data.")
        return
    end

    local offset = data.OffsetBone or vec3(0, 0, 0)

    local boneCoords = GetPedBoneCoords(data.Entity, data.IndexBone or 0, 0, 0, 0)
    local finalCoords = boneCoords + offset

    for _, item in ipairs(data.DataBind) do
        item.entity = data.Entity
    end

    return Dui.CreateInteraction({
        Coords = finalCoords,
        Visible = true,
        DataBind = data.DataBind,
    })
end

exports('createInteractionPed', function(data)
    return Dui.createInteractionPed(data)
end)

exports.LGF_Interaction:createInteractionPed({
    Entity = PlayerPedId(),
    IndexBone = 31086,
    DataBind = {
        {
            index = 1,
            title = "Option 1",
            icon = "icon1",
            description = "Description for Option 1",
            RequestedItem = { ItemName = "water", ItemCount = 3, },
            onClick = function(index, entity)
                print("You selected Option 1!")
            end
        },
        {
            index = 2,
            title = "Option 2",
            icon = "icon2",
            description = "Description for Option 2",
            onClick = function(index, entity)
                print("You selected Option 2!")
            end
        }
    }
})
