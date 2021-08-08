
#define ANTILAG_MAX_REWIND 0.3
#define ANTILAG_MAXSTATES 40
#define ANTILAG_MAX_XERP 0.1
///*
typedef struct antilag_t
{
	entity	owner;
	float	time_history[ANTILAG_MAXSTATES];
	vector	origin_history[ANTILAG_MAXSTATES];
	vector	velocity_history[ANTILAG_MAXSTATES];
	vector	angles_history[ANTILAG_MAXSTATES];
	float	frame_history[ANTILAG_MAXSTATES];
	int		moveflags_history[ANTILAG_MAXSTATES];
	
	vector 	origin_hold;
	vector 	velocity_hold;
	vector	angles_hold;
	float	frame_hold;
	int		moveflags_hold;
	
	int		rewind_seek;
	
	antilag_t *prev;
	antilag_t *next;
};

.float spawn_time;
.float client_lastupdated;
.antilag_t *antilag_state;
antilag_t *antilag_list;
//*/

void PL_SetSize(entity ent);

void antilag_update(antilag_t *data)
{
	data->rewind_seek++;
	if (data->rewind_seek >= ANTILAG_MAXSTATES)
		data->rewind_seek = 0;
	
	data->time_history[data->rewind_seek] = time;
	
	data->origin_history[data->rewind_seek] = data->owner.origin;
	data->velocity_history[data->rewind_seek] = data->owner.velocity;
	data->angles_history[data->rewind_seek] = data->owner.angles;
	data->frame_history[data->rewind_seek] = data->owner.frame;
	data->moveflags_history[data->rewind_seek] = data->owner.moveflags;
}


void antilag_list_new(entity ent)
{
	antilag_t *new = memalloc(sizeof(antilag_t));
	ent.antilag_state = new;
	new->owner = ent;
	
	if (antilag_list != __NULL__)
		antilag_list->prev = new;
	
	new->next = antilag_list;
	antilag_list = new;
}

void antilag_list_cleanup(antilag_t *data)
{
	if (antilag_list == data)
	{
		antilag_list = data->next;
	}
	
	if (data->next != __NULL__)
	{
		(data->next)->prev = data->prev;
	}
	
	if (data->prev != __NULL__)
	{
		(data->prev)->next = data->next;
	}
	
	memfree(data);
}

void antilag_unmove(antilag_t *data)
{
	data->owner.origin = data->origin_hold;
	data->owner.velocity = data->velocity_hold;
	data->owner.angles = data->angles_hold;
	data->owner.frame = data->frame_hold;
	data->owner.moveflags = data->moveflags_hold;
	PL_SetSize(data->owner);
	
	setorigin(data->owner, data->owner.origin);
}

void antilag_move(antilag_t *data, float goal_time)
{
	vector lerp_origin;
	entity owner = data->owner;
	
	//don't rewind past spawns
	//goal_time = max(goal_time, data->owner.spawn_time);
	
	int no_xerp = TRUE;
	if (data->owner->client_lastupdated > 0)
	{
		if (goal_time > data->owner.client_lastupdated)
			no_xerp = FALSE;
	}

	if (no_xerp) // this should be true unless client is stuttering a lot
	{
		int old_seek = data->rewind_seek;
		int seek = data->rewind_seek - 1;
		if (seek < 0)
			seek = ANTILAG_MAXSTATES - 1;

		float seek_time = data->time_history[seek];
		while (seek != data->rewind_seek && seek_time > goal_time)
		{
			old_seek = seek;
			seek--;
			if (seek < 0)
				seek = ANTILAG_MAXSTATES - 1;
			seek_time = data->time_history[seek];
		}

		float under_time = data->time_history[old_seek];
		float over_time = data->time_history[seek];
		float frac = (goal_time - over_time) / (under_time - over_time);
		
		if (frac <= 1)
		{
			vector diff;
			diff = data->origin_history[old_seek] - data->origin_history[seek];

			if (vlen(diff) > 48) // whoops, maybe we teleported?
				frac = 1;
			
			diff *= frac;
			lerp_origin = data->origin_history[seek] + diff;
		}
		else
		{
			float frac = (goal_time - over_time) / (time - over_time);
			frac = min(frac, 1);

			vector diff;
			diff = owner->origin - data->origin_history[data->rewind_seek];

			if (vlen(diff) > 48) // whoops, maybe we teleported?
				frac = 1;

			diff *= frac;
			lerp_origin = data->origin_history[data->rewind_seek] + diff;
			seek = data->rewind_seek;
		}
	}
	else // we need to extrapolate to make up for bad connection
	{
		lerp_origin = data->owner->origin + (data->owner->velocity * min(goal_time - data->owner.client_lastupdated, ANTILAG_MAX_XERP));
	}
	
	setorigin(owner, lerp_origin);
	owner.moveflags = data->moveflags_history[old_seek];
	PL_SetSize(owner);
}







void antilag_move_all(antilag_t *ignore, float goal_time)
{
	antilag_t *list = antilag_list;
	while (list != __NULL__)
	{
		list->origin_hold = list->owner.origin;
		list->velocity_hold = list->owner.velocity;
		list->angles_hold = list->owner.angles;
		list->frame_hold = list->owner.frame;
		list->moveflags_hold = list->owner.moveflags;
		
		if (list != ignore)
		{
			antilag_move(list, goal_time);
		}
		
		list = list->next;
	}
}

void antilag_unmove_all()
{
	antilag_t *list = antilag_list;
	while (list != __NULL__)
	{
		antilag_unmove(list);
		
		list = list->next;
	}
}

void antilag_hitscan(entity shooter)
{
	float ms = (shooter.ping / 1000);
	ms -= 0.013;
	
	ms = bound(0, ms, ANTILAG_MAX_REWIND);
	
	float goal_time = time - ms;
	antilag_move_all(shooter.antilag_state, goal_time);
}










