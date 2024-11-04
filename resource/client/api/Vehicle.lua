--- @param data table -- Interaction data for the vehicle
--- @param data.Entity any -- The vehicle entity to interact with
--- @param data.IndexBone number -- The index of the bone to get the coordinates from
--- @param data.OffsetBone vec3 -- Offset along the X, Y, and Z axes
--- @param data.DataBind table -- The data bindings for interaction options

function Dui.createInteractionVehicle(data)
    if not data or not data.Entity or not data.DataBind then
        warn("createInteractionVehicle: Missing required data.")
        return
    end

    local offset = data.OffsetBone or vec3(0, 0, 0)
    local boneIndex = data.IndexBone or 0

    local boneCoords = GetWorldPositionOfEntityBone(data.Entity, boneIndex)
    local finalCoords = boneCoords + offset

    if data.OffsetCoords then
        finalCoords = finalCoords + data.OffsetCoords
    end

    for _, item in ipairs(data.DataBind) do
        item.entity = data.Entity
    end

    return Dui.CreateInteraction({
        Coords = finalCoords,
        Visible = true,
        DataBind = data.DataBind,
    })
end

exports('createInteractionVehicle', function(data)
    local InteractionID = Dui.createInteractionVehicle(data)
    return InteractionID
end)
