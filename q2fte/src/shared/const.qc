
#define uint unsigned int
#define PLAYER_VDMGTIME		0.5f
#define PLAYER_VFALLTIME	0.3f
#define PLAYER_THINKFPS 	0.1f
#define PLAYER_PHYSFPS 		1/125

#define HEALTH_IGNORE_MAX   1
#define HEALTH_TIMED        2

#define DEFAULT_MACHINEGUN_HSPREAD  250
#define DEFAULT_MACHINEGUN_VSPREAD  250
#define DEFAULT_CHAINGUN_HSPREAD  300
#define DEFAULT_CHAINGUN_VSPREAD  500
#define DEFAULT_SHOTGUN_HSPREAD 1000
#define DEFAULT_SHOTGUN_VSPREAD 500

#define DFL_PENETRATE		1
#define DFL_ENERGY			2
#define DFL_NOKNOCKBACK		4
#define DFL_NOARMOR			8

float ARMOR_MAXIMUM[3];
float ARMOR_PROTECTION[3];
float ARMOR_ENERGY[3];
const int ARMOR_RED		= 2;
const int ARMOR_YELLOW	= 1;
const int ARMOR_GREEN	= 0;

float phys_gravity = 820;
float phys_friction = 6;
float phys_waterfriction = 1;
float phys_flyfriction = 9;

int EFFECT_IMPACT_WALL;
int	EFFECT_IMPACT_SHOTGUN;
int EFFECT_IMPACT_BLOOD;
int EFFECT_TELEPORT;
int EFFECT_EXPLOSION_ROCKET;
int EFFECT_EXPLOSION_GRENADE;
int EFFECT_EXPLOSION_BLASTER;
int EFFECT_TRAIL_ROCKET;
int EFFECT_TRAIL_GRENADE;
int EFFECT_TRAIL_RAILGUN;
int EFFECT_TRAIL_BLASTER;

.int moveflags;

const float	CHAN_AUTO			= 0;
const float	CHAN_WEAPON			= 1;
const float	CHAN_VOICE			= 2;
const float	CHAN_ITEM			= 3;
const float	CHAN_BODY			= 4;
const float	CHAN_PAIN			= 5;
const float CHAN_WEAPONSHOOT1 	= 11;
const float CHAN_WEAPONSHOOT2 	= 12;
const float CHAN_WEAPONSHOOT3 	= 13;
const float CHAN_STEP 			= 20;

const float	ATTN_NONE			= 0;
const float	ATTN_NORM			= 1;
const float	ATTN_IDLE			= 2;
const float	ATTN_STATIC			= 3;
const float ATTN_SUPPR 			= 1.6;
const float ATTN_STEP 			= 1.4;
const float ATTN_VOICE 			= 1.2;
const float ATTN_GUN 			= 0.8;
const float ATTN_GUN_BIG		= 0.6;

const float MASK_GAME = 8;

const int DEAD_NOT	= 0;
const int DEAD_DEAD	= 1;

const int DMG_TAKE_NOT		= 0;
const int DMG_TAKE_PLAYER	= 1;
const int DMG_TAKE_PROP		= 2;
const int DMG_TAKE_CORPSE	= 3;
const int DMG_TAKE_IGNORE	= 5;

const int NENT_PLAYER 	= 1;
const int NENT_SPEC 	= 2;
const int NENT_PROJ 	= 50;
const int NENT_GENERIC 	= 200;

const int NPKT_VIEWKICK		= 10;
const int NPKT_PLAYERSOUND	= 20;
const int NPKT_EFFECT_RAIL	= 30;
const int NPKT_GS_UPDATE	= 50;

const int SPECFLAG_PLAYER	= 1;
const int SPECFLAG_TEAMLOCK	= 2;

const int MF_ONLADDER = 4;
const int MF_CROUCHED = 8;
const int MF_BLOCKCROUCH = 16;

const float FL_JUMPRELEASED = 4096;
const float FL_RESPAWN 		= 4096;
const float	FL_FIRESPAWN	= 131072;
const float FL_SHOOTRELEASED= 262144;

const float STAT_PING		= 40;
const float STAT_ARMORTYPE	= 41;
const float STAT_SPECTATING	= 50;
const float STAT_READY		= 51;

const int BUTTON_FIRE		= 1;

const int NLFL_REMOTE = 0;
const int NLFL_LOCAL = 1;
const int NLFL_SPECTATE = 2;
const int NLFL_TEAM = 8;


enum int
{
	PLSOUND_JUMP,
	PLSOUND_FALL1,
	PLSOUND_FALL2,
	PLSOUND_DEATH1,
	PLSOUND_DEATH2,
	PLSOUND_DEATH3,
	PLSOUND_DEATH4,
	PLSOUND_PAIN25_1,
	PLSOUND_PAIN25_2,
	PLSOUND_PAIN50_1,
	PLSOUND_PAIN50_2,
	PLSOUND_PAIN75_1,
	PLSOUND_PAIN75_2,
	PLSOUND_PAIN100_1,
	PLSOUND_PAIN100_2,
	PLSOUND_GURP1,
	PLSOUND_GURP2,
	PLSOUND_DROWN1
};

// item spawnflags
#define ITEM_TRIGGER_SPAWN      0x00000001
#define ITEM_NO_TOUCH           0x00000002
// 6 bits reserved for editor flags
// 8 bits used as power cube id bits for coop games
#define DROPPED_ITEM            0x00010000
#define DROPPED_PLAYER_ITEM     0x00020000
#define ITEM_TARGETS_USED       0x00040000

const vector PL_MINS_STAND = '-16 -16 -24';
const vector PL_MAXS_STAND = '16 16 32';

const vector PL_MINS_CROUCH = '-16 -16 -24';
const vector PL_MAXS_CROUCH = '16 16 4';








