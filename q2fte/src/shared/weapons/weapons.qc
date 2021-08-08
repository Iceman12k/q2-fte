





void PL_WeaponSimulate(entity ent, float move_time)
{
	ent.weapon_current = WeaponList[ent.weapon];
	
	if (ent.weapon_current == __NULL__)
		return;
	
	if (ent.weapon_current->frame_func != __NULL__)
	{
		ent.weapon_current->frame_func(ent, move_time);
	}
	
	Anim_FindFrame(&ent.wep_frame, ent.weapon_current->animations[ent.wep_animation], floor(ent.wep_framenum));
	Anim_Simulate(ent, move_time, &(ent.weapon_current->animations[ent.wep_animation]), &ent.wep_frame, &ent.wep_framenum);
}

void Ammo_Init()
{
	ammo_t *amm = memalloc(sizeof(ammo_t));
	AmmoList[AMMO_SHELLS] = amm;
	amm->icon = "pics/a_shells";
	amm->netname = "shells";
	amm->maximum = 50;
	
	ammo_t *amm = memalloc(sizeof(ammo_t));
	AmmoList[AMMO_BULLETS] = amm;
	amm->icon = "pics/a_bullets";
	amm->netname = "bullets";
	amm->maximum = 200;
	
	ammo_t *amm = memalloc(sizeof(ammo_t));
	AmmoList[AMMO_GRENADES] = amm;
	amm->icon = "pics/a_grenades";
	amm->netname = "grenades";
	amm->maximum = 50;
	
	ammo_t *amm = memalloc(sizeof(ammo_t));
	AmmoList[AMMO_ROCKETS] = amm;
	amm->icon = "pics/a_rockets";
	amm->netname = "rockets";
	amm->maximum = 50;
	
	ammo_t *amm = memalloc(sizeof(ammo_t));
	AmmoList[AMMO_CELLS] = amm;
	amm->icon = "pics/a_cells";
	amm->netname = "cells";
	amm->maximum = 200;
	
	ammo_t *amm = memalloc(sizeof(ammo_t));
	AmmoList[AMMO_SLUGS] = amm;
	amm->icon = "pics/a_slugs";
	amm->netname = "slugs";
	amm->maximum = 50;
}

void W_Init()
{
	Ammo_Init();
	Blaster_Init();
	Shotgun_Init();
	SuperShotgun_Init();
	Machinegun_Init();
	Chaingun_Init();
	HandGrenade_Init();
	GrenadeLauncher_Init();
	RocketLauncher_Init();
	Hyperblaster_Init();
	Railgun_Init();
}


