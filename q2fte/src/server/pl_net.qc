

typedef struct netsync_t
{
	float		type;
	float 		fld;
	float		sendflag;
	
	
	
	netsync_t	*next;
};

.netsync_t *sync_list;
.entity		sync_storage;

void netsync_cleanuplist(entity ent)
{
	local netsync_t *list = ent.sync_list;
	while(list != __NULL__)
	{
		local netsync_t *hold = list->next;
		memfree(list);
		list = hold;
	}
	
	ent.sync_list = __NULL__;
}

void netsync_addelement(entity ent, float fld, float sendflag)
{
	netsync_t *new_sync = memalloc(sizeof(netsync_t));
	
	new_sync->next = ent.sync_list;
	ent.sync_list = new_sync;
	
	new_sync->fld = fld;
	new_sync->type = entityfieldtype(fld);
	new_sync->sendflag = sendflag;
	
	if !(ent.sync_storage)
	{
		ent.sync_storage = spawn();
		ent.sync_storage.customphysics = SUB_Null;
		ent.sync_storage.SendEntity = SUB_Null;
	}
}

void netsync_updateflags(entity ent)
{
	local netsync_t *list = ent.sync_list;
	while(list != __NULL__)
	{
		local __variant v1 = (ent).(entityfieldref(list->fld));
		local __variant v2 = (ent.sync_storage).(entityfieldref(list->fld));
		if !(v1 == v2)
		{
			ent.SendFlags |= list->sendflag;
			(ent.sync_storage).(entityfieldref(list->fld)) = (ent).(entityfieldref(list->fld));
		}
		
		list = list->next;
	}
}


void PL_Setup_Netsync()
{
	netsync_addelement(self, findentityfield("origin_x"), 2);
	netsync_addelement(self, findentityfield("origin_y"), 2);
	netsync_addelement(self, findentityfield("origin_z"), 2);
	netsync_addelement(self, findentityfield("velocity_x"), 2);
	netsync_addelement(self, findentityfield("velocity_y"), 2);
	netsync_addelement(self, findentityfield("velocity_z"), 2);
	netsync_addelement(self, findentityfield("angles_x"), 2);
	netsync_addelement(self, findentityfield("angles_y"), 2);
	
	netsync_addelement(self, findentityfield("team"), 4);
	netsync_addelement(self, findentityfield("solid"), 4);
	netsync_addelement(self, findentityfield("dimension_solid"), 4);
	netsync_addelement(self, findentityfield("dimension_hit"), 4);
	
	netsync_addelement(self, findentityfield("land_time"), 8);
	netsync_addelement(self, findentityfield("movetype"), 8);
	netsync_addelement(self, findentityfield("moveflags"), 8);
	netsync_addelement(self, findentityfield("flags"), 8);
	
	netsync_addelement(self, findentityfield("watertype"), 16);
	netsync_addelement(self, findentityfield("waterlevel"), 16);
	
	netsync_addelement(self, findentityfield("sview_height"), 32);
	
	netsync_addelement(self, findentityfield("weapon"), 64);
	netsync_addelement(self, findentityfield("weapon_wanted"), 64);
	netsync_addelement(self, findentityfield("wep_framenum"), 64);
	netsync_addelement(self, findentityfield("wep_animation"), 64);
	netsync_addelement(self, findentityfield("wep_firemode"), 64);
	
	int i;
	for(i = 0; i < MAX_AMMO; i++)
	{
		netsync_addelement(self, findentityfield(strcat("ammo_inventory[", itos(i), "]")), 128);
	}
	
	int i;
	for(i = 0; i < MAX_WEAPONS; i++)
	{
		netsync_addelement(self, findentityfield(strcat("weapon_inventory[", itos(i), "]")), 256);
	}
	
	netsync_addelement(self, findentityfield("health"), 512);
	netsync_addelement(self, findentityfield("deadflags"), 512);
	
	netsync_addelement(self, findentityfield("think_time"), 4096);
	netsync_addelement(self, findentityfield("viewkick_origin_x"), 4096);
	netsync_addelement(self, findentityfield("viewkick_origin_y"), 4096);
	netsync_addelement(self, findentityfield("viewkick_origin_z"), 4096);
	netsync_addelement(self, findentityfield("viewkick_angles_x"), 4096);
	netsync_addelement(self, findentityfield("viewkick_angles_y"), 4096);
	netsync_addelement(self, findentityfield("viewkick_angles_z"), 4096);
	netsync_addelement(self, findentityfield("viewkick_origin_l_x"), 4096);
	netsync_addelement(self, findentityfield("viewkick_origin_l_y"), 4096);
	netsync_addelement(self, findentityfield("viewkick_origin_l_z"), 4096);
	netsync_addelement(self, findentityfield("viewkick_angles_l_x"), 4096);
	netsync_addelement(self, findentityfield("viewkick_angles_l_y"), 4096);
	netsync_addelement(self, findentityfield("viewkick_angles_l_z"), 4096);
}


float PL_Spec_SendEntity(entity to, float sendflags)
{
	if (to != self)
		return FALSE;
	
	int is_watching = (self.watching != world);
	
	WriteByte(MSG_ENTITY, NENT_SPEC);
	WriteByte(MSG_ENTITY, is_watching);
	
	if (is_watching)
		return TRUE;
	
	// send pos
	WriteFloat(MSG_ENTITY, self.origin_x);
	WriteFloat(MSG_ENTITY, self.origin_y);
	WriteFloat(MSG_ENTITY, self.origin_z);
	
	// send velocity
	WriteFloat(MSG_ENTITY, self.velocity_x);
	WriteFloat(MSG_ENTITY, self.velocity_y);
	WriteFloat(MSG_ENTITY, self.velocity_z);
	
	return TRUE;
}


float PL_SendEntity(entity to, float sendflags)
{
	WriteByte(MSG_ENTITY, NENT_PLAYER);
	
	local int localflags = NLFL_REMOTE;
	if (to == self || to.watching == self)
	{
		localflags |= NLFL_LOCAL;
		
		if (to.spectating)
		{
			sendflags |= to.spec_forceflags;
			to.spec_forceflags = 0;
			
			localflags |= NLFL_SPECTATE;
		}
	}
	
	WriteLong(MSG_ENTITY, sendflags);
	WriteByte(MSG_ENTITY, localflags);
	
	if (sendflags & 2)
	{
		if (localflags & NLFL_LOCAL)
		{
			// send pos
			WriteFloat(MSG_ENTITY, self.origin_x);
			WriteFloat(MSG_ENTITY, self.origin_y);
			WriteFloat(MSG_ENTITY, self.origin_z);
			
			// send velocity
			WriteFloat(MSG_ENTITY, self.velocity_x);
			WriteFloat(MSG_ENTITY, self.velocity_y);
			WriteFloat(MSG_ENTITY, self.velocity_z);
			
			
			//send angles
			if (localflags & NLFL_SPECTATE)
			{
				//spectators need higher def angles for view smoothness
				WriteShort(MSG_ENTITY, self.v_angle_x * 100);
				WriteShort(MSG_ENTITY, self.v_angle_y * 100);
			}
			else
			{
				WriteAngle(MSG_ENTITY, self.v_angle_x);
				WriteAngle(MSG_ENTITY, self.v_angle_y);
			}
		}
		else
		{
			// send pos
			WriteFloat(MSG_ENTITY, self.origin_x);
			WriteFloat(MSG_ENTITY, self.origin_y);
			WriteFloat(MSG_ENTITY, self.origin_z);
			
			// send velocity
			WriteShort(MSG_ENTITY, self.velocity_x);
			WriteShort(MSG_ENTITY, self.velocity_y);
			WriteShort(MSG_ENTITY, self.velocity_z);
			
			//send angles
			WriteChar(MSG_ENTITY, self.v_angle_x);
			WriteAngle(MSG_ENTITY, self.v_angle_y);
		}
	}
	
	if (sendflags & 4)
	{
		WriteByte(MSG_ENTITY, self.team);
		WriteByte(MSG_ENTITY, self.solid);
		WriteByte(MSG_ENTITY, (self.dimension_hit) | (self.dimension_solid << 4));
	}
	
	if (localflags & NLFL_LOCAL)
	{
		if (sendflags & 1)
		{
			WriteFloat(MSG_ENTITY, self.client_time);
		}
		
		if (sendflags & 8)
		{
			WriteFloat(MSG_ENTITY, self.land_time);
			WriteByte(MSG_ENTITY, self.movetype);
			WriteShort(MSG_ENTITY, self.moveflags);
			WriteLong(MSG_ENTITY, self.flags);
		}
		
		if (sendflags & 16)
		{
			WriteByte(MSG_ENTITY, self.waterlevel);
			WriteByte(MSG_ENTITY, self.watertype);
		}
		
		if (sendflags & 32)
		{
			WriteFloat(MSG_ENTITY, self.sview_height);
		}
		
		if (sendflags & 64)
		{
			WriteByte(MSG_ENTITY, self.weapon);
			WriteByte(MSG_ENTITY, self.weapon_wanted);
			WriteFloat(MSG_ENTITY, self.attack_finished);
			WriteFloat(MSG_ENTITY, self.wep_framenum);
			WriteByte(MSG_ENTITY, self.wep_animation);
			WriteByte(MSG_ENTITY, self.wep_firemode);
		}
		
		if (sendflags & 128)
		{
			int i;
			for(i = 0; i < MAX_AMMO; i++)
			{
				WriteShort(MSG_ENTITY, self.ammo_inventory[i]);
			}
		}
		
		if (sendflags & 256)
		{
			int i;
			for(i = 0; i < MAX_WEAPONS; i++)
			{
				if (i <= MAX_WEAPONS - 2)
				{
					WriteByte(MSG_ENTITY, (self.weapon_inventory[i]) | (self.weapon_inventory[i + 1] << 4));
					i++;
				}
				else
					WriteByte(MSG_ENTITY, self.weapon_inventory[i]);
			}
		}
		
		if (sendflags & 512)
		{
			WriteByte(MSG_ENTITY, self.deadflags);
			WriteShort(MSG_ENTITY, self.health);
		}
		
		if (sendflags & 4096)
		{
			WriteFloat(MSG_ENTITY, self.think_time);
			
			WriteShort(MSG_ENTITY, self.viewkick_origin_x * 100); WriteShort(MSG_ENTITY, self.viewkick_origin_y * 100); WriteShort(MSG_ENTITY, self.viewkick_origin_z * 100);
			WriteShort(MSG_ENTITY, self.viewkick_origin_l_x * 100); WriteShort(MSG_ENTITY, self.viewkick_origin_l_y * 100); WriteShort(MSG_ENTITY, self.viewkick_origin_l_z * 100);
			WriteShort(MSG_ENTITY, self.viewkick_origin_g_x * 100); WriteShort(MSG_ENTITY, self.viewkick_origin_g_y * 100); WriteShort(MSG_ENTITY, self.viewkick_origin_g_z * 100);
			
			WriteShort(MSG_ENTITY, self.viewkick_angles_x * 100); WriteShort(MSG_ENTITY, self.viewkick_angles_y * 100); WriteShort(MSG_ENTITY, self.viewkick_angles_z * 100);
			WriteShort(MSG_ENTITY, self.viewkick_angles_l_x * 100); WriteShort(MSG_ENTITY, self.viewkick_angles_l_y * 100); WriteShort(MSG_ENTITY, self.viewkick_angles_l_z * 100);
			WriteShort(MSG_ENTITY, self.viewkick_angles_g_x * 100); WriteShort(MSG_ENTITY, self.viewkick_angles_g_y * 100); WriteShort(MSG_ENTITY, self.viewkick_angles_g_z * 100);
		}
	}
	else
	{
		if (sendflags & 8)
		{
			WriteByte(MSG_ENTITY, self.movetype);
			WriteByte(MSG_ENTITY, self.moveflags);
			WriteLong(MSG_ENTITY, self.flags);
		}
		
		if (sendflags & 64)
		{
			WriteByte(MSG_ENTITY, self.weapon);
		}
		
		if (sendflags & 512)
		{
			WriteByte(MSG_ENTITY, self.deadflags);
		}
	}
	
	if (sendflags & 8192)
	{
		WriteString(MSG_ENTITY, self.skin_folder);
		WriteString(MSG_ENTITY, self.skin_model);
		WriteString(MSG_ENTITY, self.skin_texture);
	}
	
	return TRUE;
}





























