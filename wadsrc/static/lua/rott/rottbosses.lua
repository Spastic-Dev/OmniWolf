--[[
  Rise of The Triad Boss Classes (rottbosses.lua)
  
  Defines the four main boss actors from ROTT (Darian, Elmo Bloth, Nith, Krist)
  with placeholder custom actions to simulate their unique combat mechanics.
--]]

local OmniWolf = require("omniwolf_api")

local ROTTBosses = {}

--=============================================================================
-- CUSTOM BOSS ACTION FUNCTIONS (Placeholders for complex behavior)
--=============================================================================

--- General Darian's attack: fires a powerful rocket or plasma blast.
--- @param actor_self table The boss actor instance.
local function A_DarianRockets(actor_self)
    -- Fire one high-damage, fast projectile.
    OmniWolf.SpawnActor("ROTT_DarianRocket", actor_self.x, actor_self.y, actor_self.z + 60, actor_self.angle)
    actor_self.PlaySound("DARIAN_ATTACK")
    OmniWolf.A_Recoil(actor_self, 50)
end

--- Elmo Bloth's attack: initiates a fast charge toward the player or a close-range melee attack.
--- @param actor_self table The boss actor instance.
local function A_ElmoCharge(actor_self)
    -- Move quickly towards the target for a few seconds.
    OmniWolf.A_SetAngle(actor_self, OmniWolf.A_GetAngleToTarget(actor_self))
    OmniWolf.A_ChangeVelocity(actor_self, 40, 0, 0, "Relative")
    actor_self.PlaySound("ELMO_CHARGE")
end

--- Nith's attack: summons or throws slow-moving, magical projectiles (like fireballs).
--- @param actor_self table The boss actor instance.
local function A_NithMagicAttack(actor_self)
    -- Fire multiple slow projectiles with slight homing capability.
    for i = -1, 1 do
        local fire_angle = OmniWolf.ApplySpread(actor_self.angle, i * 10)
        OmniWolf.SpawnActor("ROTT_NithMagicOrb", actor_self.x, actor_self.y, actor_self.z + 55, fire_angle)
    end
    actor_self.PlaySound("NITH_CAST")
end

--- Krist's unique teleport action, used to reposition frequently.
--- @param actor_self table The boss actor instance.
local function A_KristTeleport(actor_self)
    -- Teleport to a random, safe location on the map.
    local success, x, y, z = OmniWolf.FindSafeTeleportDestination(actor_self)
    if success then
        actor_self.Teleport(x, y, z)
    end
    actor_self.PlaySound("KRIST_TELEPORT")
end

--=============================================================================
-- BOSS DEFINITIONS
--=============================================================================

-- 1. GENERAL DARIAN (The Commander)
-- Slow, tanky, and utilizes heavy, ranged weaponry.
ROTTBosses.Darian = {
    Name = "GeneralDarian",
    Health = 1500,
    Speed = 8, -- Slow
    Radius = 32,
    Height = 84,
    
    States = {
        Spawn = { Sprite = "DARIAB", Duration = 10, Action = "A_Look", Loop = true },
        See = { Sprite = "DARIABCD", Duration = 5, Action = "A_Chase", Loop = true },
        Missile = {
            Sprite = "DARIEF", Duration = 8, Action = "A_FaceTarget"
            , Sprite = "DARIGH", Duration = 10, Action = A_DarianRockets, NextState = "See"
        },
        Pain = { Sprite = "DARII0", Duration = 4, Action = "A_Pain", NextState = "See" },
        Death = {
            Sprite = "DARIJKLM", Duration = 8, Action = "A_Scream"
            , Sprite = "DARINO", Duration = 6, Action = "A_BossDeathExplode"
            , Sprite = "DARIPQ", Duration = -1, NextState = "Stop" 
        }
    }
}

-- 2. ELMO BLOTH (The Guardian)
-- Fast, ground-based, and relies on rushing the player.
ROTTBosses.ElmoBloth = {
    Name = "ElmoBloth",
    Health = 1200,
    Speed = 15, -- Fast
    Radius = 30,
    Height = 68,
    
    States = {
        Spawn = { Sprite = "ELMOAB", Duration = 10, Action = "A_Look", Loop = true },
        See = { Sprite = "ELMOABCD", Duration = 3, Action = "A_Chase", Loop = true },
        Missile = {
            -- Elmo often charges, so the missile state initiates the charge action
            Sprite = "ELMOEF", Duration = 5, Action = "A_FaceTarget"
            , Sprite = "ELMOGH", Duration = 20, Action = A_ElmoCharge, NextState = "See" -- Charge lasts 20 ticks
        },
        Pain = { Sprite = "ELMOI0", Duration = 3, Action = "A_Pain", NextState = "See" },
        Death = {
            Sprite = "ELMOJKLM", Duration = 8, Action = "A_Scream"
            , Sprite = "ELMONO", Duration = 6, Action = "A_BossDeathExplode"
            , Sprite = "ELMOPQ", Duration = -1, NextState = "Stop" 
        }
    }
}

-- 3. NITH (The High Priestess)
-- Ranged magical attacks and frequent movement.
ROTTBosses.Nith = {
    Name = "Nith",
    Health = 1000,
    Speed = 10,
    Radius = 24,
    Height = 72,
    
    States = {
        Spawn = { Sprite = "NITHAB", Duration = 10, Action = "A_Look", Loop = true },
        See = { Sprite = "NITHABCD", Duration = 4, Action = "A_Chase", Loop = true },
        Missile = {
            Sprite = "NITHEF", Duration = 12, Action = "A_FaceTarget" -- Prepare
            , Sprite = "NITHGH", Duration = 8, Action = A_NithMagicAttack, NextState = "See" -- Cast
        },
        Pain = { Sprite = "NITHI0", Duration = 4, Action = "A_Pain", NextState = "See" },
        Death = {
            Sprite = "NITHJKLM", Duration = 8, Action = "A_Scream"
            , Sprite = "NITHNO", Duration = 6, Action = "A_BossDeathExplode"
            , Sprite = "NITHPQ", Duration = -1, NextState = "Stop" 
        }
    }
}

-- 4. KRIST (The Final Boss)
-- The most complex boss, using teleports and high-damage attacks.
ROTTBosses.Krist = {
    Name = "Krist",
    Health = 3000, -- Highest health
    Speed = 12,
    Radius = 36,
    Height = 96,
    
    States = {
        Spawn = { Sprite = "KRISAB", Duration = 10, Action = "A_Look", Loop = true },
        See = { 
            Sprite = "KRISABCD", 
            Duration = 3, 
            Action = "A_Chase", 
            Loop = true,
            -- Krist frequently teleports to reposition
            CheckCondition = { Condition = "Chance(20)", NextState = "Teleport" } 
        },
        Teleport = {
            Sprite = "KRISTP", Duration = 1, Action = A_KristTeleport, NextState = "See"
        },
        Missile = {
            Sprite = "KRISEF", Duration = 15, Action = "A_FaceTarget"
            -- Using Darian's attack placeholder for high damage
            , Sprite = "KRISGH", Duration = 10, Action = A_DarianRockets, NextState = "See" 
        },
        Pain = { Sprite = "KRISI0", Duration = 4, Action = "A_Pain", NextState = "See" },
        Death = {
            Sprite = "KRISJKLM", Duration = 8, Action = "A_Scream"
            , Sprite = "KRISNO", Duration = 6, Action = "A_BossDeathExplode"
            , Sprite = "KRISPQ", Duration = -1, NextState = "Stop" 
        }
    }
}

--=============================================================================
-- REGISTRATION
--=============================================================================

--- Register all defined ROTT boss classes with the engine.
if OmniWolf.RegisterActorClass then
    for name, bossDef in pairs(ROTTBosses) do
        -- Register the enemy classes with a unique prefix
        OmniWolf.RegisterActorClass("ROTTBoss_" .. name, bossDef)
        OmniWolf.Print("Registered ROTT Boss Class: ROTTBoss_" .. name)
    end
end

return ROTTBosses
