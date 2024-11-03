if not GetResourceState("LGF_Utility"):find("start") then
    Shared.debugData("WARNING", "LGF_Utility resource is not started. Running in standalone mode. Exports like createInteractionJob will not work.")
    return
end

LGF = exports.LGF_Utility:UtilityData()
