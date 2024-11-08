---@meta
---@class InteractionData
---@field position Vec4 -- Position of the interaction or ped (contains x, y, z, and rotation)
---@field model string|nil -- Model identifier for the ped (only for addInteractionPed)
---@field pedID number|nil -- Unique ID for the ped (only for addInteractionPed)
---@field dataBind InteractionItemData[] -- Array of interaction items/actions available for the interaction
---@field distance number|nil -- Maximum distance to trigger the interaction (default: 10)
---@field closest number|nil -- Closest distance for interaction trigger (default: 5)
---@field debug boolean|nil -- Flag to enable/disable debugging visuals
---@field onEnter fun(self: InteractionData): void|nil -- Function to execute when the player enters the interaction area
---@field onExit fun(self: InteractionData): void|nil -- Function to execute when the player exits the interaction area
---@field nearby fun(self: InteractionData): void|nil -- Function to execute when the player is near the interaction
---@field debugColour {r: number, g: number, b: number, a: number}|nil -- Colour for debugging the interaction (RGBA format)
InteractionData = {}

---@class InteractionItemData
---@field title string -- Title of the interaction item
---@field icon string -- Icon for the interaction item
---@field description string -- Description of the interaction item
---@field onClick fun(self: InteractionData): void -- Action to perform when the interaction item is clicked
---@field canInteract fun(distance: number, interactionid: string, myPed: number): boolean -- Condition to check if interaction with this item can happen
InteractionItemData = {}
