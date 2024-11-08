Job = {}

if not LGF then return end

function Job.hasRequiredJob(playerJob, requiredJob, requiredGrade)
    requiredGrade = requiredGrade or 0

    if type(requiredJob) == "string" then
        return playerJob.name == requiredJob and playerJob.grade >= requiredGrade
    elseif type(requiredJob) == "table" then
        for i = 1, #requiredJob do
            if playerJob.name == requiredJob[i] and playerJob.grade >= requiredGrade then
                return true
            end
        end
    end

    return false
end
