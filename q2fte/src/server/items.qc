
.float	respawn_time;

#define RESPAWNTIME_ARMOR	20
#define RESPAWNTIME_HEALTH	30
#define RESPAWNTIME_WEAPON	30
#define RESPAWNTIME_AMMO	30

void IT_Init()
{
	ARMOR_PROTECTION[ARMOR_RED] 	= 0.8;
	ARMOR_ENERGY[ARMOR_RED] 		= 0.6;
	ARMOR_MAXIMUM[ARMOR_RED] 		= 200;

	ARMOR_PROTECTION[ARMOR_YELLOW] 	= 0.6;
	ARMOR_ENERGY[ARMOR_YELLOW] 		= 0.3;
	ARMOR_MAXIMUM[ARMOR_YELLOW] 	= 100;

	ARMOR_PROTECTION[ARMOR_GREEN] 	= 0.3;
	ARMOR_ENERGY[ARMOR_GREEN] 		= 0.0;
	ARMOR_MAXIMUM[ARMOR_GREEN] 		= 50;
}


void IT_Generic_Respawn()
{
	self.solid = SOLID_TRIGGER;
	self.drawonlytoclient = world;
	
	sound(self, CHAN_ITEM, "items/respawn1.wav", 1, ATTN_IDLE);
	pointparticles(particleeffectnum("q2part.ev_item_respawn"), self.origin);
}


void IT_MegaHealth_Think()
{
    if (self.owner.health > self.owner.max_health) {
        self.nextthink = time + 1;
        self.owner.health -= 1;
        return;
    }

    if (!(self.spawnflags & DROPPED_ITEM))
	{
		self.think = IT_Generic_Respawn;
		self.nextthink = time + self.respawn_time;
	}
	else
		remove(self);
}

void IT_HealthPickup_Touch()
{
	if (!(self.style & HEALTH_IGNORE_MAX))
		if (other.health >= other.max_health)
			return;

    other.health += self.health;

    if (!(self.style & HEALTH_IGNORE_MAX))
	{
		if (other.health > other.max_health)
			other.health = other.max_health;
    }

	sound(other, CHAN_AUTO, self.noise, 1, ATTN_IDLE);
	
    if (self.style & HEALTH_TIMED)
	{
		self.think = IT_MegaHealth_Think;
		self.nextthink = time + 5;
		self.owner = other;
		self.flags |= FL_RESPAWN;
		
		
		self.solid = SOLID_NOT;
		self.drawonlytoclient = self;
    } 
	else 
	{
		if (!(self.spawnflags & DROPPED_ITEM))
		{
			self.think = IT_Generic_Respawn;
			self.nextthink = time + self.respawn_time;
			
			
			self.solid = SOLID_NOT;
			self.drawonlytoclient = self;
		}
    }
}

void IT_HealthPickup()
{
	precache_sound(self.noise);
	precache_model(self.model);
	setmodel(self, self.model);
	setsize(self, '-15 -15 -15', '15 15 15');
	
	self.touch = IT_HealthPickup_Touch;
	self.solid = SOLID_TRIGGER;
}

void spawnfunc_item_health()
{
	self.model = "models/items/healing/medium/tris";
	self.noise = "items/n_health";
	IT_HealthPickup();
	
	self.health = 10;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_HEALTH;
}

void spawnfunc_item_health_small()
{
	self.model = "models/items/healing/stimpack/tris";
	self.noise = "items/s_health";
	IT_HealthPickup();
	
	self.health = 2;
	self.style = HEALTH_IGNORE_MAX;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_HEALTH;
}

void spawnfunc_item_health_large()
{
	self.model = "models/items/healing/large/tris";
	self.noise = "items/l_health";
	IT_HealthPickup();
	
	self.health = 25;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_HEALTH;
}

void spawnfunc_item_health_mega()
{
	self.model = "models/items/mega_h/tris";
	self.noise = "items/m_health";
	IT_HealthPickup();
	
	self.health = 100;
	self.style = HEALTH_IGNORE_MAX | HEALTH_TIMED;
	
	if !(self.respawn_time)
		self.respawn_time = 20;
}






void IT_ArmorPickup_Touch()
{
	if (self.armortype == 255)
	{
		other.armorvalue += self.armorvalue;
	}
	else if (other.armorvalue == 0)
	{
		other.armorvalue = self.armorvalue;
		other.armortype = self.armortype;
	}
	else
	{
		if (self.armortype > other.armortype)
		{
            // calc new armor values
            float salvage = ARMOR_PROTECTION[other.armortype] / ARMOR_PROTECTION[self.armortype];
            int salvagecount = salvage * other.armorvalue;
            int newcount = self.armorvalue + salvagecount;
            if (newcount > ARMOR_MAXIMUM[self.armortype])
                newcount = ARMOR_MAXIMUM[self.armortype];
			
			other.armorvalue = newcount;
			other.armortype = self.armortype;
		}
		else
		{
            // calc new armor values
            salvage = ARMOR_PROTECTION[self.armortype] / ARMOR_PROTECTION[other.armortype];
            salvagecount = salvage * self.armorvalue;
            int newcount = other.armorvalue + salvagecount;
            if (newcount > ARMOR_MAXIMUM[other.armortype])
                newcount = ARMOR_MAXIMUM[other.armortype];

            // if we're already maxed out then we don't need the new armor
            if (other.armorvalue >= newcount)
                return;
			
            other.armorvalue = newcount;
		}
	}
	
	sound(other, CHAN_AUTO, self.noise, 1, ATTN_IDLE);
	self.think = IT_Generic_Respawn;
	self.nextthink = time + self.respawn_time;
	
	self.solid = SOLID_NOT;
	self.drawonlytoclient = self;
}


void IT_ArmorPickup()
{
	precache_sound(self.noise);
	precache_model(self.model);
	setmodel(self, self.model);
	setsize(self, '-15 -15 -15', '15 15 15');
	
	self.modelflags |= MF_ROTATE;
	self.touch = IT_ArmorPickup_Touch;
	self.solid = SOLID_TRIGGER;
}

void spawnfunc_item_armor_shard()
{
	self.model = "models/items/armor/shard/tris";
	self.noise = "misc/ar2_pkup";
	IT_ArmorPickup();
	
	self.armorvalue = 2;
	self.armortype = 255;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_ARMOR;
}

void spawnfunc_item_armor_jacket()
{
	self.model = "models/items/armor/jacket/tris";
	self.noise = "misc/ar1_pkup";
	IT_ArmorPickup();
	
	self.armorvalue = 25;
	self.armortype = 0;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_ARMOR;
}

void spawnfunc_item_armor_combat()
{
	self.model = "models/items/armor/combat/tris";
	self.noise = "misc/ar1_pkup";
	IT_ArmorPickup();
	
	self.armorvalue = 50;
	self.armortype = 1;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_ARMOR;
}

void spawnfunc_item_armor_body()
{
	self.model = "models/items/armor/body/tris";
	self.noise = "misc/ar3_pkup";
	IT_ArmorPickup();
	
	self.armorvalue = 100;
	self.armortype = 2;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_ARMOR;
}


void IT_WeaponPickup_Touch()
{
	int pickedup = FALSE;
	
	int i;
	for(i = 0; i < MAX_AMMO; i++)
	{
		if !(self.ammo_inventory[i])
			continue;
		
		int o_inv = other.ammo_inventory[i];
		other.ammo_inventory[i] += self.ammo_inventory[i];
		other.ammo_inventory[i] = min(other.ammo_inventory[i], (AmmoList[i])->maximum);
		
		if (o_inv != other.ammo_inventory[i])
			pickedup = TRUE;
	}
	
	int i;
	for(i = 0; i < MAX_WEAPONS; i++)
	{
		if !(self.weapon_inventory[i])
			continue;
		
		pickedup = TRUE;
		
		other.weapon_inventory[i] += self.weapon_inventory[i];
		other.weapon_inventory[i] = min(other.weapon_inventory[i], WEAPON_MAX_CARRY);
	}
	
	if (pickedup == FALSE)
		return;
	
	sound(other, CHAN_AUTO, self.noise, 1, ATTN_IDLE);
	self.think = IT_Generic_Respawn;
	self.nextthink = time + self.respawn_time;
	
	self.solid = SOLID_NOT;
	self.drawonlytoclient = self;
}

void IT_WeaponPickup()
{
	precache_sound(self.noise);
	precache_model(self.model);
	setmodel(self, self.model);
	setsize(self, '-15 -15 -15', '15 15 15');
	
	self.touch = IT_WeaponPickup_Touch;
	self.solid = SOLID_TRIGGER;
}


void spawnfunc_ammo_shells()
{
	self.model = "models/items/ammo/shells/medium/tris";
	self.noise = "misc/am_pkup";
	IT_WeaponPickup();
	
	self.ammo_inventory[AMMO_SHELLS] = 10;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_AMMO;
}


void spawnfunc_weapon_shotgun()
{
	self.weapon = WEP_SHOTGUN;
	self.model = (WeaponList[self.weapon])->w_model;
	self.noise = "misc/w_pkup";
	self.modelflags = MF_ROTATE;
	IT_WeaponPickup();
	
	self.weapon_inventory[self.weapon] = 1;
	self.ammo_inventory[(WeaponList[self.weapon])->ammo_pool] = 10;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_WEAPON;
}

void spawnfunc_weapon_supershotgun()
{
	self.weapon = WEP_SUPERSHOTGUN;
	self.model = (WeaponList[self.weapon])->w_model;
	self.noise = "misc/w_pkup";
	self.modelflags = MF_ROTATE;
	IT_WeaponPickup();
	
	self.weapon_inventory[self.weapon] = 1;
	self.ammo_inventory[(WeaponList[self.weapon])->ammo_pool] = 10;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_WEAPON;
}


void spawnfunc_ammo_bullets()
{
	self.model = "models/items/ammo/bullets/medium/tris";
	self.noise = "misc/am_pkup";
	IT_WeaponPickup();
	
	self.ammo_inventory[AMMO_BULLETS] = 50;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_AMMO;
}

void spawnfunc_weapon_machinegun()
{
	self.weapon = WEP_MACHINEGUN;
	self.model = (WeaponList[self.weapon])->w_model;
	self.noise = "misc/w_pkup";
	self.modelflags = MF_ROTATE;
	IT_WeaponPickup();
	
	self.weapon_inventory[self.weapon] = 1;
	self.ammo_inventory[(WeaponList[self.weapon])->ammo_pool] = 50;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_WEAPON;
}

void spawnfunc_weapon_chaingun()
{
	self.weapon = WEP_CHAINGUN;
	self.model = (WeaponList[self.weapon])->w_model;
	self.noise = "misc/w_pkup";
	self.modelflags = MF_ROTATE;
	IT_WeaponPickup();
	
	self.weapon_inventory[self.weapon] = 1;
	self.ammo_inventory[(WeaponList[self.weapon])->ammo_pool] = 50;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_WEAPON;
}

void spawnfunc_ammo_grenades()
{
	self.model = "models/items/ammo/grenades/medium/tris";
	self.noise = "misc/am_pkup";
	IT_WeaponPickup();
	
	self.ammo_inventory[AMMO_GRENADES] = 5;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_AMMO;
}

void spawnfunc_weapon_grenadelauncher()
{
	self.weapon = WEP_GRENADELAUNCHER;
	self.model = (WeaponList[self.weapon])->w_model;
	self.noise = "misc/w_pkup";
	self.modelflags = MF_ROTATE;
	IT_WeaponPickup();
	
	self.weapon_inventory[self.weapon] = 1;
	self.ammo_inventory[(WeaponList[self.weapon])->ammo_pool] = 5;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_WEAPON;
}

void spawnfunc_ammo_rockets()
{
	self.model = "models/items/ammo/rockets/medium/tris";
	self.noise = "misc/am_pkup";
	IT_WeaponPickup();
	
	self.ammo_inventory[AMMO_ROCKETS] = 5;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_AMMO;
}

void spawnfunc_weapon_rocketlauncher()
{
	self.weapon = WEP_ROCKETLAUNCHER;
	self.model = (WeaponList[self.weapon])->w_model;
	self.noise = "misc/w_pkup";
	self.modelflags = MF_ROTATE;
	IT_WeaponPickup();
	
	self.weapon_inventory[self.weapon] = 1;
	self.ammo_inventory[(WeaponList[self.weapon])->ammo_pool] = 5;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_WEAPON;
}

void spawnfunc_ammo_cells()
{
	self.model = "models/items/ammo/cells/medium/tris";
	self.noise = "misc/am_pkup";
	IT_WeaponPickup();
	
	self.ammo_inventory[AMMO_CELLS] = 50;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_AMMO;
}

void spawnfunc_weapon_hyperblaster()
{
	self.weapon = WEP_HYPERBLASTER;
	self.model = (WeaponList[self.weapon])->w_model;
	self.noise = "misc/w_pkup";
	self.modelflags = MF_ROTATE;
	IT_WeaponPickup();
	
	self.weapon_inventory[self.weapon] = 1;
	self.ammo_inventory[(WeaponList[self.weapon])->ammo_pool] = 50;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_WEAPON;
}

void spawnfunc_weapon_bfg10k()
{
	self.weapon = WEP_BFG10K;
	self.model = (WeaponList[self.weapon])->w_model;
	self.noise = "misc/w_pkup";
	self.modelflags = MF_ROTATE;
	IT_WeaponPickup();
	
	self.weapon_inventory[self.weapon] = 1;
	self.ammo_inventory[(WeaponList[self.weapon])->ammo_pool] = 50;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_WEAPON;
}


void spawnfunc_ammo_slugs()
{
	self.model = "models/items/ammo/slugs/medium/tris";
	self.noise = "misc/am_pkup";
	IT_WeaponPickup();
	
	self.ammo_inventory[AMMO_SLUGS] = 5;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_AMMO;
}

void spawnfunc_weapon_railgun()
{
	self.weapon = WEP_RAILGUN;
	self.model = (WeaponList[self.weapon])->w_model;
	self.noise = "misc/w_pkup";
	self.modelflags = MF_ROTATE;
	IT_WeaponPickup();
	
	self.weapon_inventory[self.weapon] = 1;
	self.ammo_inventory[(WeaponList[self.weapon])->ammo_pool] = 5;
	
	if !(self.respawn_time)
		self.respawn_time = RESPAWNTIME_WEAPON;
}










