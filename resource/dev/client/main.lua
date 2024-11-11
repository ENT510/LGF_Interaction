-- local Ped = {
--     { Position = vec4(41.1964, 6448.3623, 31.4144, 274.0062), Model = "a_f_m_fatcult_01", RequiredJob = nil, },
--     { Position = vec4(60.4139, 6434.2373, 31.2951, 231.5423), Model = "a_f_m_fatcult_01", RequiredJob = "police", }
-- }

-- for i = 1, #Ped do
--     local data = Ped[i]
--     exports.LGF_Interaction:addInteractionPed({
--         Coords = data.Position,
--         model = data.Model,
--         pedID = i,
--         dataBind = {
--             {
--                 index = 1,
--                 title = "Talk to the Ped",
--                 icon = "fa-comments",
--                 description = "This is an interaction with the ped.",
--                 onClick = function(self)
--                     exports.LGF_Interaction:removeInteraction(self.id)
--                 end,
--                 canInteract = function(distance, interactionid, myPed, vehicle)
--                     -- print(distance, interactionid, myPed, vehicle)
--                     -- if data.RequiredJob == nil or data.RequiredJob == false then return true end
--                     -- return LGF.Core:GetJob() == data.RequiredJob
--                     return true
--                 end
--             }
--         },
--         distance = 10,
--         closest = 5.0,
--         debug = true,
--         onEnter = function(self)

--         end,
--         onExit = function(self)

--         end,
--         nearby = function(self)

--         end
--     })
-- end


-- function createLockedVehicle(modelName, x, y, z, heading)
--     local model = GetHashKey(modelName)
--     RequestModel(model)
--     while not HasModelLoaded(model) do Wait(1) end
--     local vehicle = CreateVehicle(model, x, y, z, heading, true, false)
--     SetModelAsNoLongerNeeded(model)
--     return vehicle
-- end

-- local Coords = GetEntityCoords(cache.ped)
-- local veh = createLockedVehicle("kuruma", Coords.x, Coords.y, Coords.z, GetEntityHeading(cache.ped))

-- CreateThread(function()
--     local interactionID = exports.LGF_Interaction:addInteractionVehicle({
--         vehicle = veh,
--         distance = 10,
--         closest = 5.0,
--         debug = false,
--         vehicleBone = { "door_dside_f", "door_pside_f" },
--         dataBind = {
--             {
--                 index = 1,
--                 title = "Steal Vehicle",
--                 icon = "car",
--                 description = "Try to steal from this vehicle",
--                 onClick = function(self)
--                     local vehicle = self.vehicle
--                     local netID = self.netID
--                     local vehicleModel = self.vehicleModel
--                     print(("Vehicle Entity %s"):format(vehicle))
--                     print(("Vehicle Network ID %s"):format(netID))
--                     print(("Vehicle Model %s"):format(vehicleModel))
--                 end,
--                 canInteract = function(distance, interactionID, myPed, vehicleEntity)
--                     return true
--                 end
--             }
--         },
--         onEnter = function(self)
--             -- print(json.encode(self, { indent = true }))
--         end,
--         onExit = function(self)
--             -- print(json.encode(self, { indent = true }))
--             -- exports.LGF_Interaction:removeInteractionVehicle(self.vehicle)
--         end,
--         nearby = function(self)

--         end
--     })
-- end)


