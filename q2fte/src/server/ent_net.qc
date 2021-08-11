

float Proj_SendEntity(entity to, float sendflags)
{
	WriteByte(MSG_ENTITY, NENT_PROJ);
	WriteByte(MSG_ENTITY, sendflags);
	
	if (sendflags & 1)
	{
		WriteFloat(MSG_ENTITY, time);
		WriteCoord(MSG_ENTITY, self.origin_x); WriteCoord(MSG_ENTITY, self.origin_y); WriteCoord(MSG_ENTITY, self.origin_z);
		WriteFloat(MSG_ENTITY, self.velocity_x); WriteFloat(MSG_ENTITY, self.velocity_y); WriteFloat(MSG_ENTITY, self.velocity_z);
		WriteAngle(MSG_ENTITY, self.angles_x); WriteAngle(MSG_ENTITY, self.angles_y); WriteAngle(MSG_ENTITY, self.angles_z);
	}
	
	if (sendflags & 64)
	{
		WriteString(MSG_ENTITY, self.noise);
	}
	
	if (sendflags & 128)
	{
		WriteLong(MSG_ENTITY, self.modelindex);
		WriteLong(MSG_ENTITY, self.modelflags);
	}
	
	return TRUE;
}


float EntGeneric_SendEntity(entity to, float sendflags)
{
	WriteByte(MSG_ENTITY, NENT_GENERIC);
	WriteByte(MSG_ENTITY, sendflags);
	
	if (sendflags & 1)
	{
		WriteCoord(MSG_ENTITY, self.origin_x); WriteCoord(MSG_ENTITY, self.origin_y); WriteCoord(MSG_ENTITY, self.origin_z);
		WriteAngle(MSG_ENTITY, self.angles_x); WriteAngle(MSG_ENTITY, self.angles_y); WriteAngle(MSG_ENTITY, self.angles_z);
	}
	
	if (sendflags & 2)
	{
		WriteShort(MSG_ENTITY, self.effects);
	}
	
	if (sendflags & 64)
	{
		WriteByte(MSG_ENTITY, self.updaterate);
	}
	
	if (sendflags & 128)
	{
		WriteLong(MSG_ENTITY, self.modelindex);
		WriteLong(MSG_ENTITY, self.modelflags);
	}
	
	return TRUE;
}

void RailTrail_Send(entity shooter, vector start, vector end)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, NPKT_EFFECT_RAIL);
	WriteEntity(MSG_MULTICAST, shooter);
	WriteCoord(MSG_MULTICAST, start_x); WriteCoord(MSG_MULTICAST, start_y); WriteCoord(MSG_MULTICAST, start_z);
	WriteCoord(MSG_MULTICAST, end_x); WriteCoord(MSG_MULTICAST, end_y); WriteCoord(MSG_MULTICAST, end_z);
	
	multicast(shooter.origin, MULTICAST_ALL_R);
}











