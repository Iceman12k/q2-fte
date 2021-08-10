
typedef struct ammotype_t
{
	string		displayname;
	string		w_model;
	
	int			max_holdable;
};

typedef struct animframe_t
{
	float					rate;
	float					frame;
	
	void(entity ent)		func;
	string					sample;
	
	animframe_t 			*prev;
	animframe_t 			*next;
};

typedef struct animstate_t
{
	int						loop;
	
	animframe_t				*frame_list_head;
	animframe_t				*frame_list_tail;
	
	void(entity ent)		func_start;
	void(entity ent)		func_end;
};


void Anim_FindFrame(animframe_t **field, animstate_t *anim, int num)
{
	*field = __NULL__;
	if (anim == __NULL__ || anim->frame_list_head == __NULL__)
		return;
	
	animframe_t *frm = anim->frame_list_head;
	
	int i;
	for(i = 0; i < num; i++)
	{
		if (frm == __NULL__)
			return;
		
		frm = frm->next;
	}
	
	*field = frm;
}

void Anim_Simulate(entity ent, float move_time, animstate_t **anim, animframe_t **frame, float *frame_num)
{
	float f_time = *frame_num;
	f_time += move_time * (*frame)->rate;
	float frac = f_time - floor(f_time);
	
	animframe_t *frame_data = *frame;
	
	if (floor(*frame_num) < floor(f_time))
	{
		animframe_t *oldframe = frame_data;
		(*frame) = (*frame)->next;
		frame_data = *frame;
		
		if (frame_data == __NULL__)
		{
			if ((*anim)->loop)
			{
				(*frame) = (*anim)->frame_list_head;
				f_time = 0;
			}
			else
			{
				f_time = 0;
			}
			
			if ((oldframe)->func != __NULL__)
				(oldframe)->func(ent);
			
			
			if ((oldframe)->sample != __NULL__)
			{
				#ifdef SSQC
				sound(ent, CHAN_WEAPON, (oldframe)->sample, 1, ATTN_NORM);
				#endif
				#ifdef CSQC
				if (prediction_playeffects)
				{
					localsound((oldframe)->sample, CHAN_WEAPON, 1);
				}
				#endif
			}
			
			if ((*anim)->func_end != __NULL__)
				(*anim)->func_end(ent);
			
			*frame_num = f_time;
			return;
		}
		
		///*
		if ((oldframe) != __NULL__)
		{
			if ((oldframe)->func != __NULL__)
			{
				(oldframe)->func(ent);
			}
			
			if ((oldframe)->sample != __NULL__)
			{
				#ifdef SSQC
				sound(ent, CHAN_WEAPON, (oldframe)->sample, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
				#endif
				#ifdef CSQC
				if (prediction_playeffects)
				{
					localsound((oldframe)->sample, CHAN_WEAPON, 1);
				}
				#endif
			}
		}
		//*/
	}
	
	
	*frame_num = f_time;
}

void Anim_AddFrame(animframe_t **head, animframe_t **tail, float frame, float rate, void(entity ent) func, string sample)
{
	// hurray for double pointers!
	animframe_t *new_event = memalloc(sizeof(animframe_t));
	
	if ((*head) == __NULL__)
	{
		*head = new_event;
		*tail = new_event;
	}
	else
	{
		new_event->prev = (*tail);
		(*tail)->next = new_event;
		(*tail) = new_event;
	}
	
	new_event->rate = rate;
	new_event->frame = frame;
	new_event->func = func;
	new_event->sample = sample;
	
	if (sample != __NULL__)
		precache_sound(sample);
}







