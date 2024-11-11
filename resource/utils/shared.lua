local function randomID()
    if GetResourceState('LGF_Utility'):find("start") then
        LGF = LGF or exports.LGF_Utility:UtilityData()
        if LGF and LGF.string and LGF.string.RandStr then
            return LGF.string:RandStr(6, 'upp')
        else
            print('[^1ERROR^7] Failed to use LGF. Fallback to Ox Lib will be used.')
        end
    end

    return lib.string.random("A", 6)
end

return {
    randomID = randomID,
}
