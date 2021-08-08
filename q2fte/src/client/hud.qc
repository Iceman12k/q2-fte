

float autocvar_cl_drawhud


void Draw_Q2Numbers(vector pos, float scale, int value, string numstyle)
{
	value = bound(-99, value, 999);
	string v_str = itos(value);
	
	vector pic_size = [16 * scale, 24 * scale];
	
	int i;
	for(i = strlen(v_str) - 1; i >= 0; i--)
	{
		string sbstr = substring(v_str, i, 1);
		string pc;
		if (sbstr == "-")
		{
			pc = sprintf("pics/%s_minus", numstyle);
		}
		else
		{
			pc = sprintf("pics/%s_%s", numstyle, sbstr);
		}
		
		drawpic(pos, pc, pic_size, '1 1 1', 1, 0);
		pos_x -= 16 * scale;
	}
}



void HUD_Render()
{
	if !(autocvar_cl_drawhud)
		return;
	
	string hnum = "num";
	if (getstatf(STAT_HEALTH) <= 0)
		hnum = "anum";
	else if (getstatf(STAT_HEALTH) < 50 && (cltime*2) % 2 <= 1)
		hnum = "anum";
	
	vector pos;
	pos = scrsz; pos_x /= 2; pos_x -= 128; pos_y -= 24;
	Draw_Q2Numbers(pos, 1, getstatf(STAT_HEALTH), hnum);
	pos_x += 16;
	drawpic(pos, "pics/i_health", '24 24', '1 1 1', 1, 0);
	
	
	float armor_amt = getstatf(STAT_ARMOR);
	if (armor_amt)
	{
		pos = scrsz; pos_x /= 2; pos_x += 112; pos_y -= 24;
		Draw_Q2Numbers(pos, 1, armor_amt, "num");
		pos_x += 16;
		
		switch (getstatf(STAT_ARMORTYPE))
		{
			case 1: drawpic(pos, "pics/i_combatarmor", '24 24', '1 1 1', 1, 0); break;
			case 2: drawpic(pos, "pics/i_bodyarmor", '24 24', '1 1 1', 1, 0); break;
			default: drawpic(pos, "pics/i_jacketarmor", '24 24', '1 1 1', 1, 0); break;
		}
	}
	
	weapon_t *wanted_wep = WeaponList[player_localentity.weapon_wanted];
	if (wanted_wep != __NULL__)
	{
		pos = scrsz; pos_x /= 2; pos_x -= 12; pos_y -= 72;
		drawpic(pos, (wanted_wep)->icon, '24 24', '1 1 1', 1, 0);
		
		ammo_t *amm = AmmoList[wanted_wep->ammo_pool];
		if (amm != __NULL__)
		{
			pos = scrsz; pos_x /= 2; pos_y -= 24;
			drawpic(pos, amm->icon, '24 24', '1 1 1', 1, 0);
			pos_x -= 12;
			
			string amm_num = "num";
			if (player_localentity.ammo_inventory[wanted_wep->ammo_pool] == 0)
				amm_num = "anum";
			else if (player_localentity.ammo_inventory[wanted_wep->ammo_pool] <= wanted_wep->ammo_warn && (cltime*2) % 2 <= 1)
				amm_num = "anum";
			
			Draw_Q2Numbers(pos, 1, player_localentity.ammo_inventory[wanted_wep->ammo_pool], amm_num);
		}
	}
}










