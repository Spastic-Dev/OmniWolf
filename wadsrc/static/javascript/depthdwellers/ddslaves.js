/**
 * DEPTH DWELLER SLAVE (Rescue Target) Actor Definition
 *
 * This actor is an NPC (non-player character) intended to be rescued.
 * It is very fragile and uses the 'Chained' state as its default,
 * waiting for player interaction.
 */

const DepthDwellerSlaveDefinition = {
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
    }
};
