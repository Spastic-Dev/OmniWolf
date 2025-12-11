--[[
  Rise of The Triad Decorations (rottdecorations.lua)
  
  Defines static decorative actors and interactive elements like the 
  Explosive Barrel for ROTT maps.
--]]

local OmniWolf = require("omniwolf_api")

local ROTTDecorations = {}

--=============================================================================
-- CUSTOM ACTIONS
--=============================================================================

--- Spawns an explosion effect and applies damage in an area.
--- @param actor_self table The barrel actor instance.
local function A_BarrelExplosion(actor_self)
    local x, y, z = actor_self.x, actor_self.y, actor_self.z
    -- Spawn a visual explosion effect
    OmniWolf.SpawnActor("ROTTProjectile_RocketExplosion", x, y, z)
    
    -- Apply damage to all actors within the radius
    OmniWolf.A_ExplosionDamage(actor_self, 100, 50, "DEATH_EXPLOSIVE")
end

--=============================================================================
-- DECORATION DEFINITIONS
--=============================================================================

-- 1. ROTT LOGO (Iconic Spinning Logo)
ROTTDecorations.Logo = {
    Name = "ROTTLogo",
    Description = "The official spinning ROTT logo.",
    Radius = 16,
    Height = 40,
    Flags = { NO_CLIP = true, FULLBRIGHT = true }, -- Cannot be walked through, but doesn't block vision
    
    States = {
        Spawn = { Sprite = "ROTLABCD", Duration = 3, Loop = true, Action = "A_Rotate" } -- A_Rotate for spinning effect
    }
}

-- 2. FLAG POLE (Static, Solid Structure)
ROTTDecorations.FlagPole = {
    Name = "FlagPole",
    Description = "Tall, solid flag pole.",
    Radius = 16,
    Height = 128,
    Flags = { SOLID = true, STANDS_STILL = true },
    
    States = {
        Spawn = { Sprite = "FLAGA0", Duration = -1 } -- Static sprite
    }
}

-- 3. EXPLOSIVE BARREL (Interactive Hazard)
ROTTDecorations.ExplosiveBarrel = {
    Name = "ExplosiveBarrel",
    Description = "Explodes when damaged.",
    Health = 30,
    Radius = 16,
    Height = 32,
    DamageFactor = 0.5, -- Takes half damage from most sources
    Flags = { SHOOTABLE = true, STANDS_STILL = true, SOLID = true },
    
    States = {
        Spawn = { Sprite = "BRLWAB", Duration = -1 },
        Pain = { Sprite = "BRLYAA", Duration = 2, Action = "A_Pain" , NextState = "Spawn"},
        Death = {
            Sprite = "BRLYAA", Duration = 4, Action = "A_PlaySound(EXPLODE_SMALL)"
            -- Spawn explosion effect and apply damage
            , Sprite = "BRLYBB", Duration = 4, Action = A_BarrelExplosion
            , Sprite = "BRLYCC", Duration = 4, Action = "A_NoBlocking" -- Stop collision after explosion
            , Sprite = "BRLYDD", Duration = -1, NextState = "Stop" -- Remains as charred debris
        }
    }
}

-- 4. METAL DEBRIS (Floor Detail)
ROTTDecorations.MetalDebris = {
    Name = "MetalDebris",
    Description = "Small pile of metal scraps.",
    Radius = 8,
    Height = 1,
    Flags = { NO_CLIP = true, FLOORCLIP = true }, -- Cannot be seen through but does not block movement
    
    States = {
        Spawn = { Sprite = "DEBSA0", Duration = -1 }
    }
}

--=============================================================================
-- REGISTRATION
--=============================================================================

if OmniWolf.RegisterActorClass then
    for name, def in pairs(ROTTDecorations) do
        -- Register all decoration actors
        OmniWolf.RegisterActorClass("ROTTDecoration_" .. name, def)
        OmniWolf.Print("Registered ROTT Decoration: ROTTDecoration_" .. name)
    end
end

return ROTTDecorations
