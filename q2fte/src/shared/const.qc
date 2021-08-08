
#define uint unsigned int

float phys_gravity = 820;
float phys_friction = 6;
float phys_waterfriction = 1;
float phys_flyfriction = 9;

int EFFECT_IMPACT_WALL;
int EFFECT_IMPACT_BLOOD;

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
const int DMG_TAKE_IGNORE	= 3;

const int NENT_PLAYER 	= 1;
const int NENT_SPEC 	= 2;
const int NENT_LSIGHT 	= 51;

const int NPKT_VIEWKICK		= 10;
const int NPKT_HITCONFIRM	= 21;
const int NPKT_GS_UPDATE	= 50;

const int SPECFLAG_PLAYER	= 1;
const int SPECFLAG_TEAMLOCK	= 2;


const int MF_ONLADDER = 4;
const int MF_CROUCHED = 8;
const int MF_BLOCKCROUCH = 16;

const float FL_JUMPRELEASED = 4096;
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


const vector PL_MINS_STAND = '-16 -16 -24';
const vector PL_MAXS_STAND = '16 16 32';

const vector PL_MINS_CROUCH = '-16 -16 -24';
const vector PL_MAXS_CROUCH = '16 16 4';








