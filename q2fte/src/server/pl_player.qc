entity last_spawn;

void PL_SetSkin(entity ent, string mdl, string skin)
{
	ent.skin_folder = strcat("players/", mdl, "/");
	ent.skin_model = strcat(ent.skin_folder, "tris");
	ent.skin_texture = strcat(ent.skin_folder, skin);
	
	precache_model(ent.skin_model);
}

void PL_SendViewkick(entity ent, float start, float goal, float speed1, float speed2, optional int skip)
{
	ListElement_Entity *list = (ent.viewer_list)->head;
	if (skip)
	{
		list = list->next;
	}
	
	while (list != __NULL__)
	{
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, NPKT_VIEWKICK);
		WriteChar(MSG_MULTICAST, start * 4);
		WriteChar(MSG_MULTICAST, goal * 4);
		WriteByte(MSG_MULTICAST, speed1 / 2);
		WriteByte(MSG_MULTICAST, speed2 / 2);
		
		msg_entity = list->el_ent;
		multicast(ent.origin, MULTICAST_ONE_R);
		
		list = list->next;
	}
}

void PlayerPreThink()
{
	self.ping = infokeyf(self, INFOKEY_P_PING);
};

void PlayerPostThink()
{
	netsync_updateflags(self);
};



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
	
	self.health = 100;
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
	
	///*
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