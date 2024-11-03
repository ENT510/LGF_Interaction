Job = {}

if not LGF then print("Switch Mode Standalone. Download LGF_Utility to benefit from export (createInteractionJob)") return end

function Job.hasRequiredJob(playerJob, requiredJobs)
    if type(requiredJobs) == "table" then
        for i = 1, #requiredJobs do
            if playerJob == requiredJobs[i] then
                return true
            end
        end
    elseif type(requiredJobs) == "string" then
        if playerJob == requiredJobs then
            return true
        end
    end
    return false
end

function Job.hasRequiredGrade(playerGrade, requiredGrade)
    if not type(requiredGrade) == "number" then requiredGrade = tonumber(requiredGrade) end

    if playerGrade >= requiredGrade then
        return true
    end

    return false
end

function Dui.createInteractionJob(data)
    local PlayerJob = LGF.Core:GetJob()
    local PlayerGrade = LGF.Core:GetJobGrade()

    local requiredJobs = data.RequiredJob
    local requiredGrade = data.RequiredGrade or 0


    if not PlayerJob then
        warn("Missing Params Job. Use Another Functions")
        return
    end

    Shared.debugData("DEBUG", ("Player Job: %s  Required Jobs: %s"):format(PlayerJob, requiredJobs))

    if not Job.hasRequiredJob(PlayerJob, requiredJobs) then
        Shared.debugData("WARNING", "You do not have permission to create this interaction.")
        return
    end

    Shared.debugData("DEBUG", ("Player Grade: %s  Required Grade: %s"):format(PlayerGrade, requiredGrade))


    if requiredGrade and not Job.hasRequiredGrade(PlayerGrade, requiredGrade) then
        Shared.debugData("WARNING", "You do not have permission to create this interaction due to grade requirements.")
        return
    end

    



    Dui.CreateInteraction({
        Coords = data.Coords,
        Visible = true,
        DataBind = data.DataBind,
    })
end

exports('createInteractionJob', function(data)
    return Dui.createInteractionJob(data)
end)


