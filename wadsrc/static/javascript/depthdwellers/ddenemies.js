/**
 * DEPTH DWELLERS ACTORS DATA
 *
 * This data structure defines all enemies and interactive sprites in the
 * Depth Dwellers module, using a syntax inspired by the DECORATE language
 * for state-based animation and behavior.
 *
 * Sprites are defined by a 4-letter code: [Prefix][Frame][Rotation][Action/Timing]
 *
 * Key:
 * Frame: A, B, C, D...
 * Tics: Game frames (35 tics = 1 second)
 */

const DEPTH_DWELLERS_ACTORS = {

    // --- 1. HOSTILE ENEMY: RI ENFORCER (Standard Foot Soldier) ---
    RiEnforcer: {
        health: 50,
        speed: 10,              // Movement speed (map units per tic)
        radius: 0.3,            // Collision radius (in map tiles)
        height: 1.8,            // Sprite height
        painChance: 128,        // 50% chance to enter Pain state
        attackType: 'hitscan',  // Uses instant-hit laser
        damage: 15,

        // --- DECORATE-LIKE STATES ---
        states: {
            Spawn: {
                sprite: 'RIEA0', // RIE = Ri Enforcer, A = Frame, 0 = Rotation
                tics: -1,       // Hold indefinitely
                next: 'Walk',
            },
            Walk: [
                { sprite: 'RIEB0', tics: 6, action: 'A_Wander' }, // A_Wander is an engine function
                { sprite: 'RIEC0', tics: 6, action: 'A_Wander' },
                { sprite: 'RIED0', tics: 6, action: 'A_Wander' },
                { sprite: 'RIEE0', tics: 6, action: 'A_Wander' },
                { sprite: 'RIEF0', tics: 6, action: 'A_Wander', next: 'Walk' }
            ],
            See: { // When the enemy spots the player
                sprite: 'RIEA0',
                tics: 4,
                action: 'A_Chase',
                next: 'Walk', // Loop back to Walk/Chase
            },
            Missile: [ // Attack sequence (Ri Enforcer fires laser pistol)
                { sprite: 'RIEG0', tics: 10, action: 'A_FaceTarget' },
                { sprite: 'RIEH0', tics: 8, action: 'A_FireHitscan' },
                { sprite: 'RIEG0', tics: 6, next: 'Walk' }
            ],
            Pain: {
                sprite: 'RIEI0',
                tics: 5,
                action: 'A_Pain',
                next: 'Walk',
            },
            Death: [
                { sprite: 'RIEJ0', tics: 7 },
                { sprite: 'RIEK0', tics: 7 },
                { sprite: 'RIEL0', tics: 7 },
                { sprite: 'RIEM0', tics: -1, action: 'A_Remove' } // A_Remove is end state
            ]
        }
    },

    // --- 2. HOSTILE ENEMY: RI DRONE (Automated Flying Unit) ---
    RiDrone: {
        health: 30,
        speed: 12,              // Faster movement
        radius: 0.25,
        height: 1.2,            // Lower height, possibly flying
        painChance: 256,        // Always enters Pain state
        attackType: 'projectile', // Fires a physical projectile
        projectile: 'DroneBolt',  // Define the projectile type (see below)
        damage: 10,

        states: {
            Spawn: { sprite: 'DRNA0', tics: -1, next: 'Fly' },
            Fly: [
                { sprite: 'DRNB0', tics: 4, action: 'A_Look', next: 'Fly' }, // Continuous floating/flying animation
                { sprite: 'DRNC0', tics: 4, action: 'A_Chase' }
            ],
            See: {
                sprite: 'DRNA0', tics: 3, action: 'A_Chase', next: 'Fly'
            },
            Missile: [
                { sprite: 'DRND0', tics: 10, action: 'A_FaceTarget' },
                { sprite: 'DRNE0', tics: 10, action: 'A_SpawnProjectile' }, // Engine spawns the projectile
                { sprite: 'DRND0', tics: 6, next: 'Fly' }
            ],
            Pain: {
                sprite: 'DRNF0', tics: 4, action: 'A_Pain', next: 'Fly'
            },
            Death: [
                { sprite: 'DRNG0', tics: 8, action: 'A_Scream' },
                { sprite: 'DRNH0', tics: 8 },
                { sprite: 'DRNI0', tics: 8 },
                { sprite: 'DRNJ0', tics: -1, action: 'A_Remove' }
            ]
        }
    },

    // --- 3. PROJECTILE: DRONE BOLT (Fired by Ri Drone) ---
    DroneBolt: {
        health: 1, // Projectiles usually have 1 health
        speed: 25,
        radius: 0.1,
        height: 0.5,
        damage: 10,

        states: {
            Spawn: [
                { sprite: 'BLTA', tics: 3, next: 'Move' }
            ],
            Move: [
                { sprite: 'BLTA', tics: 3, action: 'A_Move' }, // Move forward
                { sprite: 'BLTB', tics: 3, action: 'A_Move', next: 'Move' }
            ],
            Death: [ // Explosion upon impact
                { sprite: 'BLTC', tics: 4, action: 'A_Explode' },
                { sprite: 'BLTD', tics: 4, action: 'A_Remove' }
            ]
        }
    },

    // --- 4. NPC/OBJECTIVE: DEPTH DWELLER SLAVE (Rescue Target) ---
    DepthDwellerSlave: {
        health: 1,              // Very fragile
        speed: 5,               // Slow, aimless wandering
        radius: 0.3,
        height: 1.8,
        // Custom flag for rescue mechanic
        isRescueTarget: true,

        states: {
            Spawn: { // Wandering Slave (rarely seen in this state)
                sprite: 'SLVA',
                tics: -1,
                next: 'Wander',
            },
            Chained: { // Default state for most slaves
                sprite: 'SLVC',
                tics: -1,
                action: 'A_WaitRescue', // Engine checks for player interaction ('E' key)
            },
            Wander: [
                { sprite: 'SLVA', tics: 8, action: 'A_Wander' },
                { sprite: 'SLVB', tics: 8, action: 'A_Wander', next: 'Wander' }
            ],
            Rescued: { // When the player uses the transport beam
                sprite: 'SLVD',
                tics: 10,
                action: 'A_BeamUp', // Visual effect/sound for teleport
                next: 'Remove',
            },
            Death: [ // If killed by enemy fire or crossfire
                { sprite: 'SLVE', tics: 7, action: 'A_Scream' },
                { sprite: 'SLVF', tics: -1, action: 'A_Remove' }
            ],
            Remove: { // Final state after rescue or death
                sprite: 'SLVF', tics: 1, action: 'A_Remove'
            }
        }
    },

    // --- 5. INTERACTABLE: COMMUNICATIONS SYSTEM (Objective Target) ---
    CommsSystem: {
        health: 100,
        radius: 0.5,
        height: 2.0,
        isObjective: true,

        states: {
            Spawn: {
                sprite: 'CMSA',
                tics: -1,
                action: 'A_ObjectiveIdle'
            },
            Death: [
                { sprite: 'CMSB', tics: 5, action: 'A_Explode' },
                { sprite: 'CMSC', tics: 5 },
                { sprite: 'CMSD', tics: -1, action: 'A_SetObjectiveComplete' }
            ]
        }
    }
};

// Example of how the engine would access the data:
function getActorState(actorName, stateName) {
    const actor = DEPTH_DWELLERS_ACTORS[actorName];
    if (actor && actor.states[stateName]) {
        return actor.states[stateName];
    }
    return null;
}

// Check an animation tic for the Ri Enforcer's walking loop
// console.log("Ri Enforcer Walk Frame 2:", getActorState('RiEnforcer', 'Walk')[1]);

// Check the death state for the Comms System objective
// console.log("Comms System Death Final Frame:", getActorState('CommsSystem', 'Death')[2]);
