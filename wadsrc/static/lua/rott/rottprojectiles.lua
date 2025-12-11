--[[
  Rise of The Triad Projectiles (rottprojectiles.lua)
  
  Defines the various projectiles and explosive effects used by ROTT weapons 
  and enemies, such as bullets, rockets, and fireballs.
--]]

local OmniWolf = require("omniwolf_api")

local ROTTProjectiles = {}

--=============================================================================
-- CUSTOM ACTIONS
--=============================================================================

--- Spawns a dedicated explosion actor at the projectile's location and kills the projectile.
--- @param actor_self table The projectile actor instance.
local function A_SpawnExplosion(actor_self)
    local x, y, z = actor_self.x, actor_self.y, actor_self.z
    local damageRadius = actor_self.ExplosionRadius or 128
    
    OmniWolf.SpawnActor("ROTT_RocketExplosion", x, y, z)
    OmniWolf.A_ExplosionDamage(actor_self, damageRadius, actor_self.Damage, "DEATH_EXPLOSIVE")
    actor_self.Destroy()
end

--=============================================================================
-- PROJECTILE DEFINITIONS
--=============================================================================

-- 1. STANDARD BULLET (Used by Low Guard, Pistols, MP40)
ROTTProjectiles.Bullet = {
    Name = "Bullet",
    Damage = 5,
    Speed = 60, -- Very fast
    Radius = 4,
    Height = 4,
    Flags = { IS_PROJECTILE = true, IS_QUICKSHOT = true },
    
    States = {
        Spawn = { Sprite = "BULTA0", Duration = 1, Loop = true },
        Impact = { Sprite = "BULTB0", Duration = 4, Action = "A_BulletImpact", NextState = "Stop" }
    }
}

-- 2. BAZOOKA ROCKET (Standard Player Rocket)
ROTTProjectiles.Rocket = {
    Name = "Rocket",
    Damage = 80,
    Speed = 35, -- Medium speed
    Radius = 8,
    Height = 8,
    ExplosionRadius = 160,
    DamageType = "DEATH_EXPLOSIVE",
    Flags = { IS_PROJECTILE = true, FULLBRIGHT = true },
    
    States = {
        Spawn = { Sprite = "ROKTAB", Duration = 3, Loop = true, Action = "A_RocketMove" },
        Impact = { Action = A_SpawnExplosion, NextState = "Stop" }
    }
}

-- 3. HEATSEEKER ROCKET (Homing Player Rocket)
ROTTProjectiles.Heatseeker = {
    Name = "Heatseeker",
    Damage = 90,
    Speed = 40,
    Radius = 8,
    Height = 8,
    ExplosionRadius = 180,
    DamageType = "DEATH_EXPLOSIVE",
    Flags = { IS_PROJECTILE = true, FULLBRIGHT = true, IS_HOMING = true }, -- IS_HOMING flag
    
    States = {
        Spawn = { Sprite = "HSTAAB", Duration = 3, Loop = true, Action = "A_SeekTarget(10, 10)" }, -- Homing action
        Impact = { Action = A_SpawnExplosion, NextState = "Stop" }
    }
}

-- 4. DEATH MONK FIREBALL (Enemy Projectile)
ROTTProjectiles.DeathMonkFireball = {
    Name = "DeathMonkFireball",
    Damage = 15,
    Speed = 15, -- Slow speed
    Radius = 10,
    Height = 10,
    DamageType = "DEATH_FIRE",
    Flags = { IS_PROJECTILE = true, FULLBRIGHT = true, IS_HOMING = true },
    
    States = {
        Spawn = { Sprite = "FIREAB", Duration = 4, Loop = true, Action = "A_SeekTarget(5, 5)" },
        Impact = { Sprite = "FIRED0", Duration = 4, Action = "A_FireDamageArea", NextState = "Stop" }
    }
}

--=============================================================================
-- EXPLOSION EFFECT DEFINITION
--=============================================================================

-- General purpose explosion actor for rockets/grenades
ROTTProjectiles.RocketExplosion = {
    Name = "RocketExplosion",
    Damage = 0, -- Damage applied by A_ExplosionDamage in the projectile's Impact state
    Radius = 40,
    Height = 40,
    Flags = { NO_CLIP = true, TRANSLUCENT = true, FULLBRIGHT = true },
    
    States = {
        Spawn = { 
            Sprite = "EXPAAABBCC", Duration = 3, Action = "A_PlaySound(EXPLODE_LARGE)"
            , Sprite = "EXPDDEEFFG", Duration = 3
            , Sprite = "EXPHHIJJKK", Duration = 3, NextState = "Stop"
        }
    }
}


--=============================================================================
-- REGISTRATION
--=============================================================================

if OmniWolf.RegisterActorClass then
    for name, def in pairs(ROTTProjectiles) do
        -- Register all actors (projectiles and effects)
        OmniWolf.RegisterActorClass("ROTTProjectile_" .. name, def)
        OmniWolf.Print("Registered ROTT Projectile/Effect: ROTTProjectile_" .. name)
    end
end

return ROTTProjectiles
