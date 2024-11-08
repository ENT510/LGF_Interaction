local Ped = {
    { Position = vec4(41.1964, 6448.3623, 31.4144, 274.0062), Model = "a_f_m_fatcult_01", RequiredJob = nil, },
    { Position = vec4(60.4139, 6434.2373, 31.2951, 231.5423), Model = "a_f_m_fatcult_01", RequiredJob = "police", }
}

for i = 1, #Ped do
    local data = Ped[i]
    exports.LGF_Interaction:addInteractionPed({
        Coords = data.Position,
        model = data.Model,
        pedID = i,
        dataBind = {
            {
                title = "Talk to the Ped",
                icon = "fa-comments",
                description = "This is an interaction with the ped.",
                onClick = function(self)
                    exports.LGF_Interaction:removeInteraction(self.id)
                end,
                canInteract = function(distance, interactionid, myPed)
                    if data.RequiredJob == nil or data.RequiredJob == false then return true end
                    return LGF.Core:GetJob() == data.RequiredJob
                end
            }
        },
        distance = 10,
        closest = 5.0,
        debug = true,
        onEnter = function(self)

        end,
        onExit = function(self)

        end,
        nearby = function(self)

        end
    })
end
