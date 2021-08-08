

int players_total;
float framecount;

float		fraglimit;

.entity		spawnpoint;
.float		damage_time;
.entity		damage_from;
.entity		watching;
.float		ping;
.float		spec_forceflags;
.float		specflags;



typedef struct ListElement_Entity
{
	entity 				el_ent;
	float				value;
	ListElement_Entity 	*next;
	ListElement_Entity	*prev;
};

typedef struct LinkedList_Entity
{
	ListElement_Entity *head;
	ListElement_Entity *tail;
};

LinkedList_Entity player_list;
.LinkedList_Entity *viewer_list;

void LinkedList_Entity_RemoveEntity(entity ent, LinkedList_Entity *lst)
{
	if (lst == __NULL__)
		return;
	
	ListElement_Entity *list = lst->head;
	
	while (list != __NULL__)
	{
		if (list->el_ent == ent)
		{
			if (list == lst->head)
				lst->head = list->next;
			if (list == lst->tail)
				lst->tail = list->prev;
			
			if (list->next != __NULL__)
				(list->next)->prev = list->prev;
			
			if (list->prev != __NULL__)
				(list->prev)->next = list->next;
			
			memfree(list);
			return;
		}
		
		
		list = list->next;
	}
}

ListElement_Entity *LinkedList_Entity_FindEntity(entity ent, LinkedList_Entity *lst)
{
	if (lst == __NULL__)
		return;
	
	ListElement_Entity *list = lst->head;
	
	while (list != __NULL__)
	{
		if (list->el_ent == ent)
		{
			return list;
		}
		
		
		list = list->next;
	}
	
	return __NULL__;
}

void LinkedList_Entity_AddEntity(entity ent, LinkedList_Entity *lst)
{
	if (lst == __NULL__)
		return;
	
	ListElement_Entity *el = memalloc(sizeof(ListElement_Entity));
	el->el_ent = ent;
	el->prev = lst->tail;
	
	if (lst->tail != __NULL__)
	{
		(lst->tail)->next = el;
		lst->tail = el;
	}
	else
	{
		lst->tail = el;
	}
	
	if (lst->head == __NULL__)
	{
		lst->head = el;
	}
}

void LinkedList_Entity_AddEntity_Sorted(entity ent, float val, LinkedList_Entity *lst)
{
	if (lst == __NULL__)
		return;
	
	ListElement_Entity *el = memalloc(sizeof(ListElement_Entity));
	el->el_ent = ent;
	el->value = val;
	
	
	ListElement_Entity *hold = __NULL__;
	ListElement_Entity *seek = lst->head;
	
	if (seek == __NULL__)
	{
		lst->head = el;
		lst->tail = el;
		return;
	}
	
	while(seek != __NULL__)
	{
		if (seek->value >= el->value)
		{
			if (seek == lst->head)
			{
				el->prev = __NULL__;
				lst->head = el;
			}
			else
			{
				el->prev = hold;
				hold->next = el;
			}
			
			seek->prev = el;
			el->next = seek;
			return;
		}
		
		hold = seek;
		seek = seek->next;
	}
	
	el->prev = hold;
	hold->next = el;
	lst->tail = el;
}

LinkedList_Entity *LinkedList_Entity_Create()
{
	LinkedList_Entity *lst = memalloc(sizeof(LinkedList_Entity));
	return lst;
}

void LinkedList_Entity_Cleanup(LinkedList_Entity *lst)
{
	ListElement_Entity *list = lst->head;
	
	while (list != __NULL__)
	{
		ListElement_Entity *hold = list->next;
		memfree(list);
		
		list = hold;
	}
	
	memfree(lst);
}



