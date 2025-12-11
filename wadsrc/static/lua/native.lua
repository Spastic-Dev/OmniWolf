--[[
  OmniWolf Native Lua API (omniwolf_api.lua)
  
  This file serves as the documentation and structure definition for the
  native C++ functions exposed to the Lua scripting environment in OmniWolf.
  
  In a production environment, these functions would be bound to the Lua state
  by the C++ engine (using the Lua/C API) and would execute the core engine logic.
--]]

local OmniWolf = {}

--=============================================================================
-- 1. ACTOR & WORLD MANAGEMENT
--=============================================================================

--- Spawns an actor of a given class at world coordinates (x, y, z).
--- @param className string The name of the actor class to spawn (e.g., "Guard", "Medikit").
--- @param x number The X coordinate (tile or world units).
--- @param y number The Y coordinate (tile or world units).
--- @param z number The Z coordinate (for 3D actors, usually 0 or floor height).
--- @param angle number The initial orientation angle (0-360).
--- @return table|nil An object reference (table) to the newly spawned actor, or nil if spawning failed.
function OmniWolf.SpawnActor(className, x, y, z, angle)
    -- C++ implementation handles class look-up, memory allocation, and placement.
end

--- Destroys an existing actor instance and cleans up its resources.
--- @param actor table The actor object reference to destroy.
--- @return boolean True if destruction was successful, false otherwise.
function OmniWolf.DestroyActor(actor)
    -- C++ implementation handles object destruction and removing it from the world lists.
end

--- Finds the first actor of a given class within a certain radius of a point.
--- @param x number Center X coordinate.
--- @param y number Center Y coordinate.
--- @param radius number The search radius.
--- @param className string|nil The class name to search for. If nil, finds any actor.
--- @return table|nil The found actor reference, or nil.
function OmniWolf.FindActorInRadius(x, y, radius, className)
    -- C++ implementation performs spatial search logic.
end

--=============================================================================
-- 2. MAP & ENVIRONMENT INTERACTION (Wolfenstein 3D Grid)
--=============================================================================

--- Gets the floor/wall tile number at a specific grid position.
--- In Wolfenstein 3D engines, this often represents the visual tile ID or a blocking status.
--- @param tileX integer The tile X coordinate (0-63).
--- @param tileY integer The tile Y coordinate (0-63).
--- @return integer The tile's value (e.g., wall ID, door status).
function OmniWolf.GetTileValue(tileX, tileY)
    -- C++ implementation accesses the map data structure.
end

--- Sets the floor/wall tile number at a specific grid position.
--- Used to open/close doors, reveal secrets, or change wall textures dynamically.
--- @param tileX integer The tile X coordinate (0-63).
--- @param tileY integer The tile Y coordinate (0-63).
--- @param value integer The new tile value to set.
function OmniWolf.SetTileValue(tileX, tileY, value)
    -- C++ implementation updates the map data and triggers redraw/collision updates.
end

--- Checks if a specific tile is a blocking wall, a closed door, or a secret.
--- @param tileX integer The tile X coordinate.
--- @param tileY integer The tile Y coordinate.
--- @return boolean True if the tile blocks movement, false otherwise.
function OmniWolf.IsTileBlocking(tileX, tileY)
    -- C++ implementation analyzes the tile value based on engine rules.
end

--=============================================================================
-- 3. PLAYER & GAME STATE
--=============================================================================

--- Gets the current player actor reference.
--- @return table|nil The player actor object, or nil if no player exists.
function OmniWolf.GetPlayer()
    -- C++ implementation returns the engine's main player object handle.
end

--- Sets the player's current health value.
--- @param health integer The new health value.
function OmniWolf.SetPlayerHealth(health)
    -- C++ implementation updates the player's health variable.
end

--- Displays a message on the player's screen (HUD).
--- @param message string The text to display.
--- @param duration number Optional. Duration in seconds. Defaults to a short time.
function OmniWolf.DisplayMessage(message, duration)
    -- C++ implementation queues the message for display by the HUD renderer.
end

--- Loads a new map or level, typically triggering a transition.
--- @param mapName string The internal name of the map to load (e.g., "E1M1", "MAP01").
function OmniWolf.ChangeLevel(mapName)
    -- C++ implementation handles the level teardown and loading process.
end

--=============================================================================
-- 4. UTILITIES & MATH
--=============================================================================

--- Prints a string to the engine's console for debugging purposes.
--- @param ... any One or more values to print.
function OmniWolf.Print(...)
    -- C++ implementation converts arguments to strings and writes to the console.
end

--- Gets the current game time, usually in tics (1/70th of a second) or milliseconds.
--- @return integer The current game tick count.
function OmniWolf.GetGameTime()
    -- C++ implementation returns the global game timer variable.
end

-- Export the OmniWolf API table as a module
return OmniWolf
