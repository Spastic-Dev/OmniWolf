--[[
  Rise of The Triad Special Death Effects Base (rottenemybase.lua)
  
  Defines generic, shared death sequences (Gib, Burn, Disintegrate)
  for ROTT enemies. It provides helper functions and state definitions
  that can be mixed into or referenced by individual enemy classes.
--]]

local OmniWolf = require("omniwolf_api")

local ROTTEffects = {}

--=============================================================================
-- 1. SHARED DEATH STATE DEFINITIONS (Assumes generic sprite names)
--=============================================================================

-- 1.1. GIB Death Sequence
ROTTEffects.GibDeath = {
    -- This sequence plays a massive explosion sound, spawns gibs, and quickly terminates
    State1 = { Sprite = "GIBDAB", Duration = 2, Action = "A_Scream" },
    State2 = { Sprite = "GIBDCB", Duration = 2, Action = "A_NoBlocking" }, -- No more collision
    State3 = { Sprite = "GIBDDE", Duration = 2, Action = "A_Explode" }, -- Spawn gibs/blood
    State4 = { Sprite = "GIBDFF", Duration = -1, NextState = "Stop" }
}

-- 1.2. BURNING Death Sequence (Fire damage)
ROTTEffects.BurnDeath = {
    -- The enemy is set on fire and slowly burns out
    State1 = { Sprite = "BRNDAB", Duration = 4, Action = "A_Scream" },
    State2 = { Sprite = "BRNDCD", Duration = 4, Action = "A_BurnSelfDamage", Loop = true,
               CheckCondition = { Condition = "Health < 1", NextState = "BurnOut" } },
    BurnOut = { 
        Sprite = "BRNDEF", Duration = 6, Action = "A_NoBlocking" 
        , Sprite = "BRNDGH", Duration = 6
        , Sprite = "BRNDIJ", Duration = -1, NextState = "Stop" -- Ash pile
    }
}

-- 1.3. DISINTEGRATION Death Sequence (Plasma/Heat damage)
ROTTEffects.DisintegrationDeath = {
    -- The enemy turns to dust/skeletal remains
    State1 = { Sprite = "DSTGAB", Duration = 3, Action = "A_Scream" },
    State2 = { Sprite = "DSTGCD", Duration = 3, Action = "A_FadeOut", Loop = true },
    State3 = { Sprite = "DSTGEF", Duration = -1, NextState = "Stop" } -- Fully dissolved
}

--=============================================================================
-- 2. HELPER ACTION FUNCTION
--=============================================================================

--- Determines which special death sequence to transition to based on
--- the type of damage the actor received in the last hit.
--- This action function should be called within the 'Death' state or
--- immediately upon health reaching zero.
--- @param actor_self table The enemy actor instance.
local function A_DetermineRotTDeath(actor_self)
    -- Get the damage type of the killing blow
    local damageType = actor_self.LastDamageType
    
    -- Check for special damage types (these names are placeholders)
    if damageType == "DEATH_GIB" or damageType == "DEATH_EXPLOSIVE" then
        actor_self.SetState("GibDeath")
        
    elseif damageType == "DEATH_FIRE" or damageType == "DEATH_BURN" then
        actor_self.SetState("BurnDeath")
        
    elseif damageType == "DEATH_PLASMA" or damageType == "DEATH_DISINTEGRATION" then
        actor_self.SetState("DisintegrationDeath")
        
    else
        -- If none of the special types, revert to the normal death state (e.g., 'Death1' in the main enemy definition)
        actor_self.SetState("NormalDeath")
    end
end

--=============================================================================
-- 3. EXPORT & INTEGRATION EXAMPLE
--=============================================================================

-- We export the function and state definitions so other Lua files can use them.
ROTTEffects.A_DetermineRotTDeath = A_DetermineRotTDeath

-- Example of how an enemy (from rottenemies.lua) would use this:
-- 1. Add the special death states to the enemy's definition table.
-- 2. In the enemy's Death state sequence, change the first action:
--    Death = {
--        Sprite = "LOWGJKLM", Duration = 6, Action = A_Scream -- First death frame
--        , Sprite = "LOWGNO", Duration = 1, Action = A_DetermineRotTDeath, NextState = "Stop" 
--    }
--    
--    If A_DetermineRotTDeath is called, it will immediately redirect to 
--    "GibDeath", "BurnDeath", "DisintegrationDeath", or fall through to 
--    the next state which should be "NormalDeath" (the standard ROTT death).

-- Since this file defines shared resources, we register the states generically
-- so they can be referenced by the SetState action in the A_DetermineRotTDeath function.
-- (Note: Actual registration might be handled by the engine's mixin system, but
-- defining them here makes them available.)

return ROTTEffects
