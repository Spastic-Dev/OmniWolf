--[[
  Rise of The Triad Enemy Classes (rottenemies.lua)
  
  Defines the primary enemy actors from ROTT, including the Low Guard,
  High Guard, and Death Monk, using the OmniWolf native Lua API for
  actor registration.
  
  This script assumes that custom action functions (like A_FireMP40)
  are either defined here or are engine-provided.
--]]

local OmniWolf = require("omniwolf_api")

local ROTTEnemies = {}

--=============================================================================
-- CUSTOM ENEMY ACTION FUNCTIONS (Placeholders for complex behavior)
--=============================================================================

--- Fires a single, low-damage pistol bullet (instant hit scan or fast projectile).
--- @param actor_self table The enemy actor instance.
local function A_FireGuardPistol(actor_self)
    local x, y, z, angle = actor_self.x, actor_self.y, actor_self.z, actor_self.angle
    -- Fire a single shot at the target
    OmniWolf.SpawnActor("ROTT_PistolBullet", x, y, z + 40, angle)
    actor_self.PlaySound("GUARD_PISTOL")
    OmniWolf.A_Recoil(actor_self, 10) -- Apply small recoil
end

--- Fires a burst of high-speed MP40 bullets.
--- @param actor_self table The enemy actor instance.
local function A_FireMP40(actor_self)
    local x, y, z, angle = actor_self.x, actor_self.y, actor_self.z, actor_self.angle
    
    -- Fire 3 bullets in a quick sequence, with slight spread
    for i = 1, 3 do
        local fire_angle = OmniWolf.ApplySpread(angle, 5)
        OmniWolf.SpawnActor("ROTT_MP40Bullet", x, y, z + 40, fire_angle)
    end
    
    actor_self.PlaySound("MP40_BURST")
    OmniWolf.A_Recoil(actor_self, 25) -- Apply medium recoil
end

--- The Death Monk's special attack: throws a slow, seeking fireball.
--- @param actor_self table The enemy actor instance.
local function A_MonkFireball(actor_self)
    local x, y, z, angle = actor_self.x, actor_self.y, actor_self.z, actor_self.angle
    -- 'ROTT_Fireball' is assumed to be a slow-moving, damage-over-time projectile
    OmniWolf.SpawnActor("ROTT_Fireball", x, y, z + 48, angle)
    actor_self.PlaySound("MONK_ATTACK")
end

--- Custom death state action for enemies that might beg for life or explode.
--- @param actor_self table The enemy actor instance.
local function A_FinalDeath(actor_self)
    -- Chance for a Death Monk to explode on death
    if actor_self.Name == "DeathMonk" and math.random(1, 10) <= 3 then -- 30% chance
        OmniWolf.SpawnActor("ROTT_ExplosionLarge", actor_self.x, actor_self.y, actor_self.z)
        OmniWolf.Print("Death Monk self-destructed!")
    end
    -- Standard GZDoom-like action to drop inventory items
    OmniWolf.A_Die(actor_self) 
end

--=============================================================================
-- ENEMY DEFINITIONS
--=============================================================================

-- 1. LOW GUARD (Pistol Grunt)
ROTTEnemies.LowGuard = {
    Name = "LowGuard",
    Health = 50,
    Speed = 10,
    Radius = 20,
    Height = 56,
    DamageFactor = 1.0,
    
    States = {
        Spawn = { Sprite = "LOWGAB", Duration = 10, Action = "A_Look", Loop = true },
        See = { Sprite = "LOWGABCD", Duration = 4, Action = "A_Chase", Loop = true },
        Missile = {
            -- Ready to shoot
            Sprite = "LOWGEF", Duration = 8, Action = "A_FaceTarget"
            -- Fire the weapon
            , Sprite = "LOWGGH", Duration = 6, Action = A_FireGuardPistol, NextState = "See"
        },
        Pain = { Sprite = "LOWGI0", Duration = 3, Action = "A_Pain", NextState = "See" },
        Death = {
            Sprite = "LOWGJKLM", Duration = 6, Action = "A_Scream"
            , Sprite = "LOWGNO", Duration = 5
            , Sprite = "LOWGPQ", Duration = -1, Action = "A_FinalDeath", NextState = "Stop" -- Final Frame
        }
    }
}

-- 2. HIGH GUARD (MP40 Trooper - Might dodge)
ROTTEnemies.HighGuard = {
    Name = "HighGuard",
    Health = 120,
    Speed = 12,
    Radius = 20,
    Height = 56,
    DamageFactor = 1.0,
    
    States = {
        Spawn = { Sprite = "HIGHAB", Duration = 10, Action = "A_Look", Loop = true },
        See = { 
            Sprite = "HIGHABCD", 
            Duration = 3, 
            Action = "A_Chase", 
            NextState = "See", 
            -- High Guards often dodge!
            CheckCondition = { Condition = "Chance(10)", NextState = "Dodge" } 
        },
        Dodge = {
            Sprite = "HIGHED", Duration = 4, Action = "A_Sidestep", NextState = "See"
        },
        Missile = {
            -- Ready to shoot
            Sprite = "HIGHEF", Duration = 5, Action = "A_FaceTarget"
            -- Fire the MP40 burst
            , Sprite = "HIGHGH", Duration = 4, Action = A_FireMP40, NextState = "See"
        },
        Pain = { Sprite = "HIGHI0", Duration = 3, Action = "A_Pain", NextState = "See" },
        Death = {
            Sprite = "HIGHJKLM", Duration = 6, Action = "A_Scream"
            , Sprite = "HIGHNO", Duration = 5
            , Sprite = "HIGHPQ", Duration = -1, Action = "A_FinalDeath", NextState = "Stop"
        }
    }
}

-- 3. DEATH MONK (Ranged Fireball/Suicide Enemy)
ROTTEnemies.DeathMonk = {
    Name = "DeathMonk",
    Health = 80,
    Speed = 10,
    Radius = 20,
    Height = 64,
    DamageFactor = 1.0,
    
    States = {
        Spawn = { Sprite = "DMONAB", Duration = 10, Action = "A_Look", Loop = true },
        See = { Sprite = "DMONABCD", Duration = 4, Action = "A_Chase", Loop = true },
        Missile = {
            -- Prepare fireball
            Sprite = "DMONEF", Duration = 10, Action = "A_FaceTarget"
            -- Throw fireball
            , Sprite = "DMONGH", Duration = 8, Action = A_MonkFireball, NextState = "See"
        },
        Pain = { Sprite = "DMONI0", Duration = 3, Action = "A_Pain", NextState = "See" },
        Death = {
            -- Note: A_FinalDeath handles the 30% chance of explosion
            Sprite = "DMONJKLM", Duration = 6, Action = "A_Scream"
            , Sprite = "DMONNO", Duration = 5
            , Sprite = "DMONPQ", Duration = -1, Action = A_FinalDeath, NextState = "Stop" 
        }
    }
}

--=============================================================================
-- REGISTRATION
--=============================================================================

--- Register all defined ROTT enemy classes with the engine.
if OmniWolf.RegisterActorClass then
    for name, enemyDef in pairs(ROTTEnemies) do
        -- Register the enemy classes
        OmniWolf.RegisterActorClass("ROTTEnemy_" .. name, enemyDef)
        OmniWolf.Print("Registered ROTT Enemy Class: ROTTEnemy_" .. name)
    end
end

return ROTTEnemies
