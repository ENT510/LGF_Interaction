--- @meta

--- @class vec3
--- A class representing a three-dimensional vector.
--- @field x number The X coordinate.
--- @field y number The Y coordinate.
--- @field z number The Z coordinate.

--- @class InteractionData
--- A class representing interaction data.
--- @field Coords vec3 The coordinates where the interaction occurs.
--- @field Visible boolean Indicates if the interaction is currently visible.
--- @field DataBind table A table containing data bindings for interaction options.

--- @class ModelInfo
--- A class representing model information.
--- @field model number The model identifier.
--- @field coords vec3 The coordinates of the model.
--- @field entity any The game entity associated with the model.

--- @class DataBindItem
--- A class representing an individual data binding item.
--- @field index number The index of the item.
--- @field title string The title of the item.
--- @field icon string The icon associated with the item.
--- @field description string The description of the item.
--- @field image string The image associated with the item.
--- @field buttonColor string The color of the button.
--- @field RequestedItem table The item requested for the interaction.
--- @field onClick function The function to be executed when the item is clicked.

--- @class JobData
--- A class representing job-related interaction data.
--- @field RequiredJob table|string The required job(s) to create the interaction.
--- @field RequiredGrade number The required grade for the job.

--- @type activeInteractions table<string, InteractionData>
--- A table tracking active interactions indexed by interaction ID.

--- @type DuiObject
--- A reference to the Dui object for rendering UI elements.

--- @section Dui Functions

--- @type function Dui.createInteractionGlobalModel(data: { 
---     DataBind: DataBindItem[], 
---     Model: table, 
---     Distance: number?, 
---     OffsetCoords: vec3? 
--- }): void
--- Creates global interactions based on the model provided.

--- @type function Dui.createInteractionVehicle(data: { 
---     Entity: any, 
---     IndexBone: number, 
---     OffsetBone: vec3?, 
---     DataBind: DataBindItem[] 
--- }): void
--- Creates interactions for vehicles.

--- @type function Dui.CreateInteraction(data: InteractionData): string
--- Creates a new interaction and returns its ID.

--- @type function Dui.removeInteractionById(interactionID: string): void
--- Removes an interaction by its ID.

--- @type function Dui.getInteractionById(interactionID: string): InteractionData?
--- Retrieves interaction data by its ID.

--- @section Job Functions

--- @type function Job.hasRequiredJob(playerJob: string, requiredJobs: table|string): boolean
--- Checks if the player has the required job(s).

--- @type function Job.hasRequiredGrade(playerGrade: number, requiredGrade: number): boolean
--- Checks if the player meets the required grade for the interaction.

--- @section Interaction Creation Functions

--- @type function Dui.createInteractionJob(data: { 
---     Coords: vec3, 
---     DataBind: DataBindItem[], 
---     RequiredJob: table|string, 
---     RequiredGrade: number? 
--- }): void
--- Creates an interaction that requires specific job and grade conditions.
