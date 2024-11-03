# LGF Interaction System

The **LGF Interaction System** is a **DUI Handler** designed to facilitate dynamic interactions with various in-game entities, including pedestrians, vehicles, and models. Built on the **DUI (Draw User Interface)** system, it provides a seamless way for players to interact with the game world through a user-friendly interface. This system leverages the power of **NUI (New User Interface)** to display interaction menus, enhancing the overall gameplay experience.
All registered interactions in the LGF Interaction System return a unique interaction ID. This feature allows server owners and developers to easily manage and reference specific interactions, enabling flexible removal and modification without affecting others.

## Available Interaction Types

1. **Create Interaction with Pedestrian**:  
   Initiates an interaction menu when a player approaches a pedestrian.

```lua copy
exports.LGF_Interaction:createInteractionPed(data)
```

2. **Create Interaction with Vehicle** (`createInteractionVehicle`):  
   Allows players to interact with nearby vehicles, providing options like opening or closing doors.

```lua copy
exports.LGF_Interaction:createInteractionVehicle(data)
```

3. **Create Interaction with Job** (`createInteractionJob`):  
   Enables interaction menus that can only be accessed by players with specific job roles, ensuring that interactions are relevant to the player's current occupation in the game.

```lua copy
exports.LGF_Interaction:createInteractionJob(data)
```

4. **Create Interaction with Model** (`createInteractionGlobalModel`):  
   Facilitates interactions with specific in-game models, allowing each specified model to have its own unique interaction.  
   The UI is created for **all instances** of the specified models present in the game world. This means that when a player is within range of any of these models, they can access the defined interaction options, enhancing the interactivity of the game environment.

```lua copy
exports.LGF_Interaction:createInteractionGlobalModel(data)
```

5. **Close Interaction** (`closeInteraction`):  
   Closes any open interaction menus, ensuring a smooth transition back to normal gameplay.

```lua copy
exports.LGF_Interaction:closeInteraction(data)
```

6. **Remove Interaction by ID:**:
   Removes a specific interaction based on its unique interaction ID, allowing for precise control over which interactions are active in the game.

```lua copy
exports.LGF_Interaction:removeInteractionById(interactionID)
```


## Features

- **Dynamic Interaction Points**:  
  Enables interactions with pedestrians, vehicles, and models based on proximity, making the world feel more immersive and responsive.

- **Customizable**:  
  Easily modify interaction options through Lua tables, allowing server owners to tailor the interactions to their specific needs.

- **User-Friendly Interface**:  
  Integrates with NUI for displaying interaction menus, ensuring that players have an intuitive and visually appealing experience.

- **Job-Based Interactions**:  
  The `createInteractionJob` function allows for the creation of interaction menus that are restricted to certain job roles. This adds a layer of role-playing to the game, as only players with the specified jobs can access these interactions.
