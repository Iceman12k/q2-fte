

//this is run before we load fully
void main()
{
	localcmd("echo Server starting\n");
	
}

//very start of frame, before anything else is run
void StartFrame()
{
	deathmatch = cvar("deathmatch");
	fraglimit = max(cvar("fraglimit"), 1);
	framecount = framecount + 1;
}

//very end of frame, nothing is run after this
void EndFrame()
{
	
}

//world model spawn func, basically init function
void worldspawn()
{
	clientstat(STAT_ARMORTYPE, EV_FLOAT, armortype);
	
	W_Init();
	IT_Init();
	
	clientstat(STAT_PING, EV_FLOAT, ping);
}

void SpectatorThink()
{
	
}

void SpectatorDisconnect()
{
	bprint(self.netname);
	bprint(" disconnected from the spectators.\n");
}

void SpectatorConnect()
{
	bprint(self.netname);
	bprint(" has joined the spectators.\n");
}

