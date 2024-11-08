Shared = {}
local colors = { DEBUG = "^5", WARNING = "^3", INFO = "^4", ERROR = "^1", DEFAULT = "^0" }

function Shared.getConvarBool(convarName, defaultValue)
    local value = GetConvar(convarName, tostring(defaultValue))
    return value == "true"
end

function Shared.formatValue(args)
    if type(args) == 'function' then
        return "Function: " .. msgpack.unpack(msgpack.pack(tostring(args)))
    elseif type(args) == 'table' then
        return json.encode(args, { sort_keys = true, indent = true })
    else
        return tostring(args)
    end
end

function Shared.debugData(level, ...)
    if not Shared.getConvarBool("LGF_Interaction.enableDebug", true) then return end

    local args = { ... }

    for i = 1, #args do args[i] = Shared.formatValue(args[i]) end

    local colorPrefixes = {
        ["DEBUG"] = colors.DEBUG .. "[DEBUG] " .. colors.DEFAULT,
        ["WARNING"] = colors.WARNING .. "[WARNING] " .. colors.DEFAULT,
        ["INFO"] = colors.INFO .. "[INFO] " .. colors.DEFAULT,
        ["ERROR"] = colors.ERROR .. "[ERROR] " .. colors.DEFAULT
    }

    local colorPrefix = colorPrefixes[level] or colors.DEFAULT .. "[LOG] " .. colors.DEFAULT
    local finalMessage = colorPrefix .. table.concat(args, " | ")

    print(finalMessage)
end

function Shared.printTypeError(expectedType, actualType, variableName)
    local colorExpected = "^2"
    local colorActual = "^1"
    local colorVariable = "^4"
    local colorReset = "^0"

    local message = ("Type Error: Expected %s%s%s but got %s%s%s for variable '%s%s%s'"):format(
        colorExpected, expectedType, colorReset,
        colorActual, actualType, colorReset,
        colorVariable, variableName, colorReset
    )

    Shared.debugData("WARNING", message)
end
