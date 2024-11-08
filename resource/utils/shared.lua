local libResourcesState = {
    ['LGF_Utility'] = GetResourceState('LGF_Utility') ~= 'missing',
    ['ox_lib'] = GetResourceState('ox_lib') ~= 'missing',
    ['ox_inventory'] = GetResourceState('ox_inventory') ~= 'missing'
}

local function IsLibResource(resource)
    if libResourcesState[resource] then
        return true
    else
        print(('[^1ERROR^7] %s is Missing!'):format(resource))
        return false
    end
end

local function randomID()
    if IsLibResource('LGF_Utility') then
        if LGF ~= nil and LGF.string and LGF.string.RandStr then
            return LGF.string:RandStr(6, 'upp')
        else
            LGF = exports.LGF_Utility:UtilityData()
            if LGF and LGF.string and LGF.string.RandStr then
                return LGF.string:RandStr(6, 'upp')
            else
                print('[^1ERROR^7] Failed to initialize LGF. Using fallback for random ID generation.')
            end
        end
    end
    return tostring(math.random(100000, 999999))
end



return {
    randomID = randomID,
}
