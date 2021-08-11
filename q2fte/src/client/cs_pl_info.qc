
#define PLAYERSOUNDS_MAX 	24

typedef struct playerinfo_t
{
	string	folder;
	string	model;
	string	skin;
	float	skin_file;
	
	string	sounds[PLAYERSOUNDS_MAX];
};

string			player_sounddef[PLAYERSOUNDS_MAX];
playerinfo_t 	*PlayerInfo[256];

void PlayerInfo_UpdateSounds(playerinfo_t *info)
{
	int i;
	for(i = 0; i < PLAYERSOUNDS_MAX; i++)
	{
		if (player_sounddef[i] == __NULL__)
			continue;
		
		info->sounds[i] = sprintf(player_sounddef[i], info->folder);
		
		searchhandle shand = search_begin(strcat(info->sounds[i], ".*"), SB_CASEINSENSITIVE, TRUE);
		if (search_getsize(shand) <= 0)
		{
			info->sounds[i] = (PlayerInfo[255])->sounds[i];
		}
		if (shand > 0)
			search_end(shand);
		
		precache_sound(info->sounds[i]);
	}
}

void PlayerInfo_Update(int index, string folder, string skin)
{
	if (index > 255)
		return;
	
	playerinfo_t *pinfo = PlayerInfo[index];
	if (pinfo == __NULL__)
	{
		pinfo = memalloc(sizeof(playerinfo_t));
		PlayerInfo[index] = pinfo;
	}
	
	string o_model = pinfo->model;
	
	// verify model
	searchhandle shand = search_begin(strcat(folder, "tris.*"), SB_CASEINSENSITIVE, TRUE);
	if (search_getsize(shand) <= 0)
	{
		folder = "players/male/";
		skin = "grunt";
	}
	if (shand > 0)
		search_end(shand);
	// verify skin
	searchhandle shand = search_begin(strcat(folder, skin, ".*"), SB_CASEINSENSITIVE, TRUE);
	if (search_getsize(shand) <= 0)
	{
		
		if (folder == "players/female/")
			skin = "athena";
		else
		{
			folder = "players/male/";
			skin = "grunt";
		}
	}
	if (shand > 0)
		search_end(shand);
	//
	
	pinfo->folder = folder;
	pinfo->model = strcat(folder, "tris");
	pinfo->skin = strcat(folder, skin);
	
	if (o_model != pinfo->model)
	{
		PlayerInfo_UpdateSounds(pinfo);
	}
}

void PlayerInfo_SoundDefInit()
{
	player_sounddef[PLSOUND_JUMP] = 	"%sjump1";
	player_sounddef[PLSOUND_FALL1] = 	"%sfall1";
	player_sounddef[PLSOUND_FALL2] = 	"%sfall2";
	player_sounddef[PLSOUND_DEATH1] = 	"%sdeath1";
	player_sounddef[PLSOUND_DEATH2] = 	"%sdeath2";
	player_sounddef[PLSOUND_DEATH3] = 	"%sdeath3";
	player_sounddef[PLSOUND_DEATH4] = 	"%sdeath4";
	player_sounddef[PLSOUND_PAIN25_1] = "%spain25_1";
	player_sounddef[PLSOUND_PAIN25_2] = "%spain25_2";
	player_sounddef[PLSOUND_PAIN50_1] = "%spain50_1";
	player_sounddef[PLSOUND_PAIN50_2] = "%spain50_2";
	player_sounddef[PLSOUND_PAIN75_1] = "%spain75_1";
	player_sounddef[PLSOUND_PAIN75_2] =	"%spain75_2";
	player_sounddef[PLSOUND_PAIN100_1] ="%spain100_1";
	player_sounddef[PLSOUND_PAIN100_2] ="%spain100_2";
	player_sounddef[PLSOUND_GURP1] = 	"%sgurp1";
	player_sounddef[PLSOUND_GURP2] = 	"%sgurp2";
	player_sounddef[PLSOUND_DROWN1] = 	"%sdrown1";
	
	PlayerInfo_Update(255, "players/male/", "grunt");
}





void NetRead_PlayerSound()
{
	float entnum = ReadEntityNum();
	entity ent = edict_num(entnum);
	vector org = [ReadCoord(), ReadCoord(), ReadCoord()];
	float chan = ReadByte();
	int snd = ReadByte();
	float vol = ReadByte() / 100;
	float attn = ReadByte() / 50;
	
	int ent_created = FALSE;
	if (ent == world || TRUE)
	{
		ent_created = TRUE;
		ent = spawn();
		ent.origin = org;
	}
	
	playerinfo_t *pinfo = PlayerInfo[255];
	if (entnum < 255)
	{
		if (PlayerInfo[entnum] != __NULL__)
			pinfo = PlayerInfo[entnum];
	}
	
	if (entnum == player_localentnum)
		localsound(pinfo->sounds[snd], chan, vol);
	else
		sound(ent, chan, pinfo->sounds[snd], vol, attn);
	
	if (ent_created)
		remove(ent);
}









