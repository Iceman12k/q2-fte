





const int WEP_ANIM_IDLE1	= 0;
const int WEP_ANIM_IDLE2	= 1;

const int WEP_ANIM_DRAW1	= 5;
const int WEP_ANIM_DRAW2	= 6;

const int WEP_ANIM_FIRE1	= 11;
const int WEP_ANIM_FIRE2	= 12;
const int WEP_ANIM_FIRE3	= 13;

const int WEP_ANIM_PUTAWAY1	= 21;
const int WEP_ANIM_PUTAWAY2	= 22;

const int AMMO_NULL			= 0;
const int AMMO_SHELLS		= 1;
const int AMMO_BULLETS		= 2;
const int AMMO_GRENADES		= 3;
const int AMMO_ROCKETS		= 4;
const int AMMO_CELLS		= 5;
const int AMMO_SLUGS		= 6;

const int WEP_BLASTER 		= 1;
const int WEP_SHOTGUN 		= 2;
const int WEP_SUPERSHOTGUN	= 3;
const int WEP_MACHINEGUN	= 4;
const int WEP_CHAINGUN		= 5;
const int WEP_HANDGRENADE	= 6;
const int WEP_GRENADELAUNCHER= 7;
const int WEP_ROCKETLAUNCHER= 8;
const int WEP_HYPERBLASTER	= 9;
const int WEP_RAILGUN		= 10;
const int WEP_BFG10K		= 11;

#define MAX_AMMO 			7
#define MAX_WEAPONS 		12
#define WEAPON_MAX_CARRY	3

typedef struct ammo_t
{
	string		netname;
	string		icon;
	
	int			maximum;
};

ammo_t			*AmmoList[MAX_AMMO];
.int			ammo_inventory[MAX_AMMO];

typedef struct weapon_t
{
	string		netname;
	string		w_model;
	string		v_model;
	string		h_model;
	string		icon;
	
	int			ammo_min;
	int			ammo_pool;
	int			ammo_warn;
	float		draw_time;
	void		frame_func(entity ent, float move_time);
	
	animstate_t *animations[32];
};

weapon_t		*WeaponList[MAX_WEAPONS];
.int			weapon_inventory[MAX_WEAPONS];
.float			weapon_wanted;
.weapon_t		*weapon_current;
.animframe_t 	*wep_frame;
.float			wep_framenum;
.int			wep_animation;
.int			wep_firemode;


void Weapon_StartAnimation(entity ent, int animation)
{
	ent.wep_framenum = 0;
	ent.wep_animation = animation;
	ent.wep_frame = (ent.weapon_current->animations[animation])->frame_list_head;
	
	if ((ent.weapon_current->animations[animation])->func_start != __NULL__)
		(ent.weapon_current->animations[animation])->func_start(ent);
}

void Weapon_Generic_Idle(entity ent)
{
	ent.flags -= (ent.flags & FL_SHOOTRELEASED);
	Weapon_StartAnimation(ent, WEP_ANIM_IDLE1);
}

void Weapon_Putaway(entity ent)
{
	Weapon_StartAnimation(ent, WEP_ANIM_PUTAWAY1);
	ent.attack_finished = ent.client_time + 2;
}

void Weapon_Swap(entity ent)
{
	ent.wep_firemode = 0;
	ent.flags -= (ent.flags & FL_SHOOTRELEASED);
	ent.weapon = ent.weapon_wanted;
	Weapon_StartAnimation(ent, WEP_ANIM_DRAW1);
	ent.attack_finished = ent.client_time + (WeaponList[ent.weapon])->draw_time;
}

void Weapon_Generic_OutofAmmo(entity ent)
{
	ent.weapon_wanted = WEP_BLASTER;
	
	#ifdef SSQC
	sound(ent, CHAN_WEAPON, "weapons/noammo", 1, ATTN_STATIC);
	#endif
	#ifdef CSQC
	if (prediction_playeffects)
	{
		localsound("weapons/noammo", CHAN_WEAPON, 1);
	}
	#endif
}
