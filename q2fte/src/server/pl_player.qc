entity last_spawn;

void PL_SetSkin(entity ent, string mdl, string skin)
{
	ent.skin_folder = strcat("players/", mdl, "/");
	ent.skin_model = strcat(ent.skin_folder, "tris");
	ent.skin_texture = strcat(ent.skin_folder, skin);
	
	precache_model(ent.skin_model);
}

void PlayerPreThink()
{
	self.ping = infokeyf(self, INFOKEY_P_PING);
};

void PlayerPostThink()
{
	netsync_updateflags(self);
};

void PL_DamageFeedback(entity ent)
{
	vector vdmg_angles;
	int count = (ent.damage_blood + ent.damage_armor + ent.damage_parmor);
    if !(count)
        return;
	
    int realcount = count;
    count = max(10, count);
	
    ent.damage_alpha = count * 0.01;
	ent.damage_alpha = bound(0.2, ent.damage_alpha, 0.6);
	
	vector damage_blend;
    if (ent.damage_parmor)
		damage_blend += ((float)ent.damage_parmor / realcount) * '0 1 0';
    if (ent.damage_armor)
		damage_blend += ((float)ent.damage_armor / realcount) * '1 1 1';
    if (ent.damage_blood)
		damage_blend += ((float)ent.damage_blood / realcount) * '0.8 0 0';
	
	
	makevectors(ent.v_angle);
	float kick = fabs(ent.damage_knockback);
    if (kick && ent.health > 0) { // kick of 0 means no view adjust at all
        kick = kick * 100 / ent.health;

        if (kick < count * 0.5f)
            kick = count * 0.5f;
        if (kick > 50)
            kick = 50;
		
		vector v = ent.damage_pos - ent.origin;
		v = normalize(v);
		
        float side = v * v_right;
        vdmg_angles[2] = kick * side * 0.3;

        side = -(v * v_forward);
        vdmg_angles[0] = kick * side * 0.3;
    }
	
	
	ListElement_Entity *list = (ent.viewer_list)->head;
	while (list != __NULL__)
	{
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, NPKT_VIEWKICK);
		WriteCoord(MSG_MULTICAST, vdmg_angles[0]); WriteCoord(MSG_MULTICAST, vdmg_angles[2]);
		WriteShort(MSG_MULTICAST, damage_blend[0] * 100); WriteShort(MSG_MULTICAST, damage_blend[1] * 100); WriteShort(MSG_MULTICAST, damage_blend[2] * 100);
		WriteByte(MSG_MULTICAST, ent.damage_alpha * 100);
		
		msg_entity = list->el_ent;
		multicast(ent.origin, MULTICAST_ONE_R);
		
		list = list->next;
	}
	
	ent.damage_parmor = 0;
	ent.damage_armor = 0;
	ent.damage_blood = 0;
	ent.damage_knockback = 0;
	ent.damage_alpha = 0;
	ent.damage_pos = 0;
}

//called when a client connects to the server
void ClientConnect(optional float csqcactive)
{
	players_total++;
	
	LinkedList_Entity_RemoveEntity(self, self.watching.viewer_list);
	
	PL_SetSkin(self, "male", "grunt");
	
	bprint(self.netname); //print player name
	bprint(" connected.\n");
	PL_Setup_Netsync();
	
	self.team = 0;
	self.SendFlags |= 16384;
	
	self.viewer_list = LinkedList_Entity_Create();
	LinkedList_Entity_AddEntity(self, self.viewer_list);
	LinkedList_Entity_AddEntity(self, &player_list);
	
	antilag_list_new(self);
};


void PlayerSpawn()
{
	if (self.spawnpoint == world)
		self.spawnpoint = spawnpoint_choose(self);
	
	if (self.watching != world)
	{
		if (self.watching.viewer_list != __NULL__)
			LinkedList_Entity_RemoveEntity(self, self.watching.viewer_list);
	}
	
	self.watching = world;
	self.spectating = FALSE;
	self.view2 = world;
	self.specflags = SPECFLAG_PLAYER;
	
	self.spawn_time = time;
	self.classname = "player";
	self.solid = SOLID_SLIDEBOX;
	self.hitcontentsmaski = CONTENTBIT_SOLID|CONTENTBIT_BODY|0x00000002i|CONTENTBIT_PLAYERCLIP;
	self.dimension_hit = 2;
	self.dimension_solid = 1;
	setmodel(self, self.skin_model);
	self.movetype = MOVETYPE_WALK;
	
	self.armorvalue = 0;
	self.armortype = 0;
	
	self.mass = 200;
	
	self.max_health = 100;
	self.health = self.max_health;
	self.damage_from = world;
	
	setorigin(self, self.spawnpoint.origin + [0,0,1]);
	self.velocity = 0;
	
	self.takedamage = DMG_TAKE_PLAYER;
	self.deadflags = DEAD_NOT;
	
	self.flags = FL_CLIENT | FL_FIRESPAWN;
	self.moveflags = 0;
	
	self.angles = self.spawnpoint.angles;
	self.fixangle = TRUE;
	setsize(self, PL_MINS_STAND, PL_MAXS_STAND);
	self.view_ofs = '0 0 22';
	self.SendEntity = PL_SendEntity;
	self.spawnpoint = world;
	
	self.attack_finished = 0;
	
	self.weapon = WEP_BLASTER;
	self.weapon_wanted = WEP_BLASTER;
	self.weapon_current = WeaponList[self.weapon];
	self.weapon_inventory[WEP_BLASTER] = 1;
	self.weapon_inventory[WEP_HANDGRENADE] = 1;
	
	/*
	self.weapon = WEP_BFG10K;
	self.weapon_wanted = WEP_BFG10K;
	self.ammo_inventory[(WeaponList[self.weapon])->ammo_pool] = 50;
	self.weapon_current = WeaponList[self.weapon];
	self.weapon_inventory[self.weapon] = 1;
	//*/
	
	self.items = 0;
};

void PlayerRespawn()
{
	PlayerSpawn();
}

//called when a client loads a map
void PutClientInServer()
{
	PlayerSpawn();
};

void ClientKill()
{
	self.frags--;
	
	self.health = 0;
	PL_Death(self.origin, self, self, 0);
	
	if (time > self.damage_time + 2)
		self.damage_from = self;
};

//called when client disconnects from the server
void ClientDisconnect()
{
	bprint(self.netname);
	bprint(" has left the game.\n");
	
	if (self.watching.viewer_list != __NULL__)
	{
		LinkedList_Entity_RemoveEntity(self, self.watching.viewer_list);
	}
	
	LinkedList_Entity_Cleanup(self.viewer_list);
	LinkedList_Entity_RemoveEntity(self, &player_list);
	antilag_list_cleanup(self.antilag_state);
	netsync_cleanuplist(self);
};


void SetNewParms()
{
	
};

void SetChangeParms()
{
	
};

void SV_RunClientCommand()
{
	
	PL_RunPhysics();
	self.SendFlags |= 1;
	
	antilag_update(self->antilag_state);
	self.client_lastupdated = time;
}