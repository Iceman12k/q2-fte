
void CSQC_RendererRestarted(string rendererdescription)
{
	
}

void CSQC_Init(float apilevel, string enginename, float engineversion)
{
	registercommand("spectate");
	registercommand("ready");
	registercommand("use");
	
	loadfont("", "arial", "24", FONT_HUD, 0, 0);
	loadfont("", "arial", "outline=2", FONT_HUD, 0, 0);
	
	PlayerInfo_SoundDefInit();
	W_Init();
	viewmodel_primary = spawn();
	
	searchhandle shand = search_begin("gfx/*/*.png", SB_CASEINSENSITIVE, TRUE);
	if (shand > 0)
	{
		int i;
		for(i = 0; i < search_getsize(shand); i++)
		{
			precache_pic(search_getfilename(shand, i));
			print("precaching: ", search_getfilename(shand, i), "\n");
		}
		
		search_end(shand);
	}
	
	searchhandle shand = search_begin("gfx/xhair/*.png", SB_CASEINSENSITIVE, TRUE);
	if (shand > 0)
	{
		int i;
		for(i = 0; i < search_getsize(shand); i++)
		{
			string fname = search_getfilename(shand, i);
			precache_pic(fname);
			
			shaderforname(substring(fname, 0, strlen(fname) - 4), strcat("{\nprogram default2d\naffine\n{\nmap ", fname, "\nrgbgen vertex\nalphagen vertex\nblendfunc blend\n}\n}\n"));
		}
		
		search_end(shand);
	}
}

float CSQC_Event_Sound(float entnum, float channel, string soundname, float vol, float attenuation, vector pos, float pitchmod, float flags)
{
	if (entnum == player_localentnum && !is_spectator)
	{
		if (channel == CHAN_WEAPON || (channel >= CHAN_WEAPONSHOOT1 && channel <= CHAN_WEAPONSHOOT3))
			return TRUE;
	}
	
	
	return FALSE;
}

void CSQC_Parse_Event()
{
	int msg_type = ReadByte();
	
	switch (msg_type)
	{
		case NPKT_VIEWKICK: NetRead_ViewKick(); break;
		case NPKT_PLAYERSOUND: NetRead_PlayerSound(); break;
		case NPKT_EFFECT_RAIL: NetRead_Effect_Rail(); break;
	}
}

void CSQC_Ent_Update(float isnew)
{
	
	local int entity_type = ReadByte();
	
	switch (entity_type)
	{
		case NENT_PLAYER: EntUpdate_Player(isnew); break;
		case NENT_PROJ: EntUpdate_Proj(isnew); break;
		case NENT_GENERIC: EntUpdate_Generic(isnew); break;
	}
}

void CSQC_Ent_Remove()
{
	if (self.server_state != __NULL__)
	{
		memfree(self.server_state);
	}
	
	if (self.predicted_state != __NULL__)
	{
		memfree(self.predicted_state);
	}
	
	if (self.hold_state != __NULL__)
	{
		memfree(self.hold_state);
	}
	
	if (self.weapon_held)
		remove(self.weapon_held);
	
	if (self.cleanup_func != __NULL__)
		self.cleanup_func();
	
	remove(self);
}

float scoreboard_mode;

float argc;
float CMD_Use()
{
	string wep = strtolower(argv(1));
	string wep2 = strtolower(argv(2));
	
	if (wep == "blaster")
		cmd_forceimpulse = WEP_BLASTER;
	else if (wep == "shotgun")
		cmd_forceimpulse = WEP_SHOTGUN;
	else if (wep == "super" && wep2 == "shotgun")
		cmd_forceimpulse = WEP_SUPERSHOTGUN;
	else if (wep == "machinegun")
		cmd_forceimpulse = WEP_MACHINEGUN;
	else if (wep == "chaingun")
		cmd_forceimpulse = WEP_CHAINGUN;
	else if (wep == "grenades")
		cmd_forceimpulse = WEP_HANDGRENADE;
	else if (wep == "grenade" && wep2 == "launcher")
		cmd_forceimpulse = WEP_GRENADELAUNCHER;
	else if (wep == "rocket" && wep2 == "launcher")
		cmd_forceimpulse = WEP_ROCKETLAUNCHER;
	else if (wep == "hyperblaster")
		cmd_forceimpulse = WEP_HYPERBLASTER;
	else if (wep == "railgun")
		cmd_forceimpulse = WEP_RAILGUN;
	else if (wep == "bfg10k")
		cmd_forceimpulse = WEP_BFG10K;
	else 
		return FALSE;
	
	return TRUE;
}

float(string cmd) CSQC_ConsoleCommand =
{
	argc = tokenize(cmd);
	cmd = argv(0);
	
	if (cmd == "+showscores")
	{
		scoreboard_mode = TRUE;
	}
	else if (cmd == "-showscores")
	{
		scoreboard_mode = FALSE;
	}
	else if (cmd == "spectate")
	{
		//localcmd("cmd ", cmd, "\n");
		localcmd("cmd observe\n");
	}
	else if (cmd == "ready")
	{
		localcmd("cmd ", cmd, "\n");
	}
	else if (cmd == "use")
	{
		return CMD_Use();
	}
	else 
	{
		return FALSE;
	}
	
	return TRUE;
}


float autocvar_cl_forwardspeed;
float autocvar_cl_sidespeed;
float autocvar_cl_upspeed;
void CSQC_Input_Frame()
{
	input_movevalues_x /= autocvar_cl_forwardspeed;
	input_movevalues_y /= autocvar_cl_sidespeed;
	input_movevalues_z /= autocvar_cl_upspeed;
	
	input_movevalues_x *= 50;
	input_movevalues_y *= 50;
	input_movevalues_z *= 50;
	
	if (cmd_forceimpulse)
	{
		input_impulse = cmd_forceimpulse;
		cmd_forceimpulse = 0;
	}
}



void CSQC_UpdateView(float vwidth, float vheight, float notmenu)
{	
	scrsz = [vwidth, vheight];
	
	view_fov = cvar("fov");
	
	clearscene();
	addentities(MASK_ENGINE|MASK_GAME);
	setproperty(VF_AFOV, view_fov);
	setproperty(VF_DRAWCROSSHAIR, TRUE);
	renderscene();
	
	drawfill('0 0', scrsz, player_localentity.vdmg_blend_draw, player_localentity.vdmg_alpha_draw);
	
	HUD_Render();
}







