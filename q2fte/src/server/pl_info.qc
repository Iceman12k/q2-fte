

void PL_Sound(entity ent, float channel, int num, float vol, float attn)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, NPKT_PLAYERSOUND);
	WriteEntity(MSG_MULTICAST, ent);
	WriteCoord(MSG_MULTICAST, ent.origin_x); WriteCoord(MSG_MULTICAST, ent.origin_y); WriteCoord(MSG_MULTICAST, ent.origin_z);
	WriteByte(MSG_MULTICAST, channel);
	WriteByte(MSG_MULTICAST, num);
	WriteByte(MSG_MULTICAST, vol * 100);
	WriteByte(MSG_MULTICAST, attn * 50);
	
	multicast(ent.origin, MULTICAST_PHS);
}







