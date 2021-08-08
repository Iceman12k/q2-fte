

#define RANDSPAWN_NUM	3
#define SPAWN_Z_COEFF	0.35

LinkedList_Entity 	spawnpoint_list;
int					spawnpoint_total;


entity spawnpoint_choose(entity ent)
{
	LinkedList_Entity *sorted_list = LinkedList_Entity_Create();
	
	ListElement_Entity *el;
	for(el = spawnpoint_list->head; el != __NULL__; el = el->next)
	{
		vector spawn_org = (el->el_ent).origin; spawn_org[2] *= SPAWN_Z_COEFF;
		float dist = 90000 + (random() * 10000);
		antilag_t *player;
		for(player = antilag_list; player != __NULL__; player = player->next)
		{
			if ((player->owner).deadflags != DEAD_NOT)
			
			if (player->owner == ent)
				continue;
			
			vector player_org = (player->owner).origin; player_org[2] *= SPAWN_Z_COEFF;
			float this_dist = vlen(player_org - spawn_org) + (random() * 150);
			
			if (this_dist < dist)
				dist = this_dist;
		}
		
		tracebox((el->el_ent).origin + '0 0 1', PL_MINS_STAND, PL_MAXS_STAND, (el->el_ent).origin + '0 0 2', MOVE_NORMAL, ent);
		if (trace_startsolid)
			continue;
		
		LinkedList_Entity_AddEntity_Sorted(el->el_ent, dist, sorted_list);
		//LinkedList_Entity_AddEntity(el->el_ent, sorted_list);
	}
	
	if (sorted_list->head != __NULL__)
	{
		int chosen = floor(random() * min(spawnpoint_total - 1, RANDSPAWN_NUM));
		int i;
		for(i = 0, el = sorted_list->tail; i < chosen && el != __NULL__; i++, el = el->prev);
		entity spawn_chosen = el->el_ent;
		LinkedList_Entity_Cleanup(sorted_list);
		
		return spawn_chosen;
	}
	else
	{
		print("ALL SPAWNS BLOCKED\n");
		LinkedList_Entity_Cleanup(sorted_list);
		return (spawnpoint_list->head)->el_ent;
	}
	
	
	
	
}

void spawnpoint_start()
{
	LinkedList_Entity_AddEntity(self, &spawnpoint_list);
	spawnpoint_total++;
}

void info_player_start()
{
	spawnpoint_start();
};

void info_player_deathmatch()
{
	spawnpoint_start();
};

void info_player_team2()
{
	self.team = 2;
	//spawnpoint_start();
};

void info_player_team1()
{
	self.team = 1;
	//spawnpoint_start();
};











