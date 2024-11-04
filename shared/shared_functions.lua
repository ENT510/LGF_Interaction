Shared = {}

function Shared.getConvarBool(convarName, defaultValue)
    local value = GetConvar(convarName, tostring(defaultValue))
    return value == "true"
end

function Shared.debugData(type, ...)
    if not Shared.getConvarBool("LGF_Interaction.enableDebug", false) then return end

    local args = { ... }
    local debugMessage = ""
    local colors = { DEBUG = "^5", WARNING = "^3", INFO = "^4", ERROR = "^1", DEFAULT = "^0" }

    local color = colors[type] or colors.DEFAULT
    debugMessage = color .. "[" .. type .. "]" .. colors.DEFAULT .. " "

    local formattedArgs = {}
    for _, v in ipairs(args) do
        table.insert(formattedArgs, tostring(v))
    end

    debugMessage = debugMessage .. table.concat(formattedArgs, ", ")
    print(debugMessage)
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
