/**
 * SHADOWCASTER PLAYER ACTOR DEFINITION
 *
 * This TypeScript structure defines the core states and properties for the
 * player character in the Shadowcaster module, following a DECORATE-like
 * syntax for compatibility with the OmniWolf/Raven Engine structure.
 *
 * Sprites: PLY[Frame][Rotation]
 * Rotation is generally 0 for the player actor itself.
 */

// --- TYPE DEFINITIONS for DECORATE-like Structure ---

type Action = string; // Engine function call (e.g., 'A_FireWeapon', 'A_Warp')
type StateName = string;

interface ActorState {
    sprite: string;
    tics: number; // Tics to hold the frame (35 tics = 1 second)
    action?: Action;
    next?: StateName;
}

interface ActorDefinition {
    health: number;
    speed: number;
    radius: number;
    height: number;
    type: 'player';
    // Base states are an array to allow for simple animation loops
    states: { [key: string]: ActorState | ActorState[] };
}

// --- ACTOR DATA ---

const SHADOWCASTER_ACTORS: { [key: string]: ActorDefinition } = {

    // --- 1. PLAYER ACTOR ---
    ShadowcasterPlayer: {
        health: 100,
        speed: 15,              // Base movement speed
        radius: 0.3,            // Player collision radius
        height: 1.8,            // Player visual height
        type: 'player',

        states: {
            Spawn: {
                sprite: 'PLYRA0', // Default spawn pose
                tics: 1,
                action: 'A_GiveDefaultWeapon', // Ensure player has a weapon
                next: 'Ready',
            },
            Ready: { // Idle state (Player standing still, weapon visible)
                sprite: 'PLYRA0',
                tics: 1,
                action: 'A_WeaponReady', // Engine draws the weapon sprite
                next: 'Ready',
            },
            Walk: [ // Walking/Moving animation loop
                { sprite: 'PLYRB0', tics: 4, action: 'A_WeaponBob' },
                { sprite: 'PLYRC0', tics: 4, action: 'A_WeaponBob' },
                { sprite: 'PLYRD0', tics: 4, action: 'A_WeaponBob' },
                { sprite: 'PLYRE0', tics: 4, action: 'A_WeaponBob', next: 'Walk' }
            ],
            Pain: { // When the player takes damage
                sprite: 'PLYRF0',
                tics: 5,
                action: 'A_Pain', // Engine applies screen flash/recoil effect
                next: 'Ready',
            },
            Attack: { // Generic attack state (used by the engine if a weapon is fired)
                // Note: The actual attack animation sequence is often defined on the weapon itself.
                // This state is primarily for player recoil feedback.
                sprite: 'PLYRG0',
                tics: 6,
                action: 'A_StartWeaponFire',
                next: 'Ready',
            },
            Death: [ // Player death sequence
                { sprite: 'PLYRH0', tics: 8, action: 'A_Scream' },
                { sprite: 'PLYRI0', tics: 8 },
                { sprite: 'PLYRJ0', tics: 8 },
                { sprite: 'PLYRK0', tics: 10, action: 'A_Fall' }, // Player hits the ground
                { sprite: 'PLYRL0', tics: -1, next: 'FinalDeath' } // Hold last frame
            ],
            FinalDeath: {
                sprite: 'PLYRL0', // Hold the final death pose
                tics: -1,
                action: 'A_PlayerKilled' // Engine displays death screen
            },
            // --- Raven Engine additions (Conceptual) ---
            Jump: {
                sprite: 'PLYRM0',
                tics: 10,
                action: 'A_JumpMomentum', // Add vertical momentum
                next: 'Walk', // Return to walk state after the jump impulse
            },
        }
    }
};
