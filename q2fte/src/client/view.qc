

void NetRead_ViewKick()
{
	self = player_localentity;
	
	self.vdmg_time = cltime + 0.5;
	self.vdmg_angles[0] = ReadCoord();
	self.vdmg_angles[2] = ReadCoord();
	self.vdmg_blend = [ReadShort(), ReadShort(), ReadShort()] / 100;
	self.vdmg_alpha = ReadByte() / 100;
	
	
	self.damage_alpha = bound(0.1, self.damage_alpha, 0.4);
	self.vdmg_blend_draw = self.vdmg_blend;
	
}