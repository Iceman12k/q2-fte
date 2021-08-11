

/*
==================
ClipVelocity

Slide off of the impacting object
returns the blocked flags (1 = floor, 2 = step / wall)
==================
*/
#define STOP_EPSILON    0.1f
vector ClipVelocity(vector in, vector normal, vector out, float overbounce)
{
    float   backoff;
    float   change;
    int     i, blocked;
	
    blocked = 0;
    if (normal[2] > 0)
        blocked |= 1;       // floor
    if (!normal[2])
        blocked |= 2;       // step
	
    backoff = dotproduct(in, normal) * overbounce;
	
    for (i = 0 ; i < 3 ; i++) {
        change = normal[i] * backoff;
        out[i] = in[i] - change;
        if (out[i] > -STOP_EPSILON && out[i] < STOP_EPSILON)
            out[i] = 0;
    }
	
    return out;
}



/*
============
PM_FlyMove

The basic solid body movement clip that slides along multiple planes
Returns the clipflags if the velocity was modified (hit something solid)
1 = floor
2 = wall / step
4 = dead stop
============
*/
#define MAX_CLIP_PLANES 5
int PM_FlyMove(entity ent, float move_time)
{
    entity     	hit;
    int         bumpcount, numbumps;
    vector      dir;
    float       d;
    int         numplanes;
    vector      planes[MAX_CLIP_PLANES];
    vector      primal_velocity, original_velocity, new_velocity;
    int         i, j;
    trace_t     trace;
    vector      end;
    float       time_left;
    int         blocked;

    numbumps = 4;

    blocked = 0;
	original_velocity = ent.velocity;
	primal_velocity = ent.velocity;
    numplanes = 0;

    time_left = move_time;

    ent.groundentity = world;
    for (bumpcount = 0 ; bumpcount < numbumps ; bumpcount++) {
        for (i = 0 ; i < 3 ; i++)
            end[i] = ent.origin[i] + time_left * ent.velocity[i];
		
        tracebox_full(&trace, ent.origin, ent.mins, ent.maxs, end, MOVE_NORMAL, ent);

        if (trace.allsolid) {
            // entity is trapped in another solid
            ent.velocity = 0;
            return 3;
        }

        if (trace.fraction > 0) {
            // actually covered some distance
			ent.origin = trace.endpos;
			original_velocity = ent.velocity;
            numplanes = 0;
        }

        if (trace.fraction == 1)
            break;     // moved the entire distance
		
        hit = trace.ent;

        if (trace.plane_normal[2] > 0.7f) {
            blocked |= 1;       // floor
            if (hit.solid == SOLID_BSP) {
                ent.groundentity = hit;
            }
        }
        if (!trace.plane_normal[2]) {
            blocked |= 2;       // step
        }

//
// run the impact function
//
        //SV_Impact(ent, &trace);
		/*
        if (!ent.inuse)
            break;      // removed by the impact function
		*/


        time_left -= time_left * trace.fraction;

        // cliped to another plane
        if (numplanes >= MAX_CLIP_PLANES) {
            // this shouldn't really happen
            ent.velocity = 0;
            return 3;
        }
		
		planes[numplanes] = trace.plane_normal;
        numplanes++;

//
// modify original_velocity so it parallels all of the clip planes
//
        for (i = 0 ; i < numplanes ; i++) {
            new_velocity = ClipVelocity(original_velocity, planes[i], new_velocity, 1.01);

            for (j = 0 ; j < numplanes ; j++)
                if ((j != i) && (planes[i] != planes[j])) {
                    if (dotproduct(new_velocity, planes[j]) < 0)
                        break;  // not ok
                }
            if (j == numplanes)
                break;
        }

        if (i != numplanes) {
            // go along this plane
			ent->velocity = new_velocity;
        } else {
            // go along the crease
            if (numplanes != 2) {
//              gi.dprintf ("clip velocity, numplanes == %i\n",numplanes);
				ent.velocity = 0;
                return 7;
            }
            CrossProduct(planes[0], planes[1], dir);
            d = dotproduct(dir, ent->velocity);
            ent.velocity = dir * d;
        }

//
// if original velocity is against the original velocity, stop dead
// to avoid tiny occilations in sloping corners
//
        if (dotproduct(ent->velocity, primal_velocity) <= 0) {
            ent.velocity = 0;
            return blocked;
        }
    }

    return blocked;
}



/*
==================
PM_StepSlideMove

Each intersection will try to step over the obstruction instead of
sliding along it.

Returns a new origin, velocity, and contact entity
Does not modify any world state?
==================
*/
#define STEPSIZE    18
#define MIN_STEP_NORMAL 0.7f    // can't step up onto very steep slopes
#define MAX_CLIP_PLANES 5
#define MAXTOUCH 5

.float numtouch;
.entity touchents[MAXTOUCH];

void PM_StepSlideMove_(entity ent, float move_time)
{
    int         bumpcount, numbumps;
    vector      dir;
    float       d;
    int         numplanes;
    vector      planes[MAX_CLIP_PLANES];
    vector      primal_velocity;
    int         i, j;
    trace_t trace;
    vector      end;
    float       time_left;

    numbumps = 4;
	
	primal_velocity = ent.velocity;
    numplanes = 0;

    time_left = move_time;

    for (bumpcount = 0; bumpcount < numbumps; bumpcount++) {
        for (i = 0; i < 3; i++)
            end[i] = ent.origin[i] + time_left * ent.velocity[i];
			
		tracebox_full(&trace, ent.origin, ent.mins, ent.maxs, end, MOVE_NORMAL, ent);

        if (trace.allsolid) {
            // entity is trapped in another solid
            ent.velocity[2] = 0;    // don't build up falling damage
            return;
        }

        if (trace.fraction > 0) {
            // actually covered some distance
			ent.origin = trace.endpos;
            numplanes = 0;
        }

        if (trace.fraction == 1)
            break;     // moved the entire distance

        // save entity for contact
        if (ent.numtouch < MAXTOUCH && trace.ent) {
            ent.touchents[ent.numtouch] = trace.ent;
            ent.numtouch++;
        }

        time_left -= time_left * trace.fraction;

        // slide along this plane
        if (numplanes >= MAX_CLIP_PLANES) {
            // this shouldn't really happen
			ent.velocity = 0;
            break;
        }
		
		planes[numplanes] = trace.plane_normal;
        numplanes++;

//
// modify original_velocity so it parallels all of the clip planes
//
        for (i = 0; i < numplanes; i++) {
            ent.velocity = ClipVelocity(ent.velocity, planes[i], ent.velocity, 1.01);
            for (j = 0; j < numplanes; j++)
                if (j != i) {
                    if (dotproduct(ent.velocity, planes[j]) < 0)
                        break;  // not ok
                }
            if (j == numplanes)
                break;
        }

        if (i != numplanes) {
            // go along this plane
        } else {
            // go along the crease
            if (numplanes != 2) {
                ent.velocity = 0;
                break;
            }
            //CrossProduct(planes[0], planes[1], dir);
			dir = crossproduct(planes[0], planes[1]);
            d = dotproduct(dir, ent.velocity);
            ent.velocity = dir * d;
        }

        //
        // if velocity is against the original velocity, stop dead
        // to avoid tiny occilations in sloping corners
        //
        if (dotproduct(ent.velocity, primal_velocity) <= 0) {
            ent.velocity = 0;
            break;
        }
    }

    //if (pm->s.pm_time)
    //    VectorCopy(primal_velocity, ent.velocity);
}

/*
==================
PM_StepSlideMove

==================
*/
void PM_StepSlideMove(entity ent, float move_time)
{
    vector      start_o, start_v;
    vector      down_o, down_v;
    trace_t     trace;
    float       down_dist, up_dist;
    vector      up, down;
	
	start_o = ent.origin;
	start_v = ent.velocity;

    PM_StepSlideMove_(ent, move_time);
	
	down_o = ent.origin;
	down_v = ent.velocity;
	
	up = start_o;
    up[2] += STEPSIZE;
	
	tracebox_full(&trace, up, ent.mins, ent.maxs, up, MOVE_NORMAL, ent);
    if (trace.allsolid)
        return;     // can't step up

    // try sliding above
	ent.origin = up;
	ent.velocity = start_v;

    PM_StepSlideMove_(ent, move_time);

    // push down the final amount
    down = ent.origin;
    down[2] -= STEPSIZE;
	
	if (input_buttons & 4 && vlen(ent.velocity) < 240)//(ent.moveflags & MF_CROUCHED)
	{
		down[2] -= 6;
	}
	
	tracebox_full(&trace, ent.origin, ent.mins, ent.maxs, down, MOVE_NORMAL, ent);
    if (!trace.allsolid)
        ent.origin = trace.endpos;
	
	if (trace.plane_normal[2] > 0.95 && !(ent.moveflags & MF_ONLADDER))
	{
		local float diff = (start_o[2] - ent.origin[2]);
		if (diff < -4)
			ent.sview_height += min(diff, 0);
	}
	
	up = ent.origin;

    // decide which one went farther
    down_dist = (down_o[0] - start_o[0]) * (down_o[0] - start_o[0])
                + (down_o[1] - start_o[1]) * (down_o[1] - start_o[1]);
    up_dist = (up[0] - start_o[0]) * (up[0] - start_o[0])
              + (up[1] - start_o[1]) * (up[1] - start_o[1]);

    if (down_dist > up_dist || trace.plane_normal[2] < MIN_STEP_NORMAL) {
		ent.origin = down_o;
		ent.velocity = down_v;
        return;
    }
    //!! Special case
    // if we were walking along a plane, then we need to copy the Z over
    ent.velocity[2] = down_v[2];
}


#define STOPSPEED			100
#define ACCEL				10
#define ACCEL_WATER			10
#define MAXSPEED			300
#define MAXSPEED_CROUCH		100
#define MAXSPEED_WATERMULT	0.5

/*
==============
PM_Accelerate

Handles user intended acceleration
==============
*/
static void PM_Accelerate(entity ent, vector wishdir, float wishspeed, float accel, float move_time)
{
    int         i;
    float       addspeed, accelspeed, currentspeed;

    currentspeed = dotproduct(ent.velocity, wishdir);
    addspeed = wishspeed - currentspeed;
    if (addspeed <= 0)
        return;
    accelspeed = accel * move_time * wishspeed;
    if (accelspeed > addspeed)
        accelspeed = addspeed;

    for (i = 0; i < 3; i++)
        ent.velocity[i] += accelspeed * wishdir[i];
}

static void PM_AirAccelerate(entity ent, vector wishdir, float wishspeed, float accel, float move_time)
{
    int         i;
    float       addspeed, accelspeed, currentspeed, wishspd = wishspeed;

    if (wishspd > 30)
        wishspd = 30;
    currentspeed = dotproduct(ent.velocity, wishdir);
    addspeed = wishspd - currentspeed;
    if (addspeed <= 0)
        return;
    accelspeed = accel * wishspeed * move_time;
    if (accelspeed > addspeed)
        accelspeed = addspeed;

    for (i = 0; i < 3; i++)
        ent.velocity[i] += accelspeed * wishdir[i];
}

void PM_Friction(entity ent, float move_time)
{
    float   speed, newspeed, control;
    float   friction;
    float   drop;
	
	friction = phys_friction;

    speed = vlen(ent.velocity);
    if (speed < 1) {
        ent.velocity[0] = 0;
        ent.velocity[1] = 0;
        return;
    }

    drop = 0;
	// apply ground friction
    //if ((ent.flags & FL_ONGROUND) || (ent.moveflags & MF_ONLADDER)) {
	if ((ent.flags & FL_ONGROUND) || (ent.moveflags & MF_ONLADDER)) {
        control = speed < STOPSPEED ? STOPSPEED : speed;
        drop += control * friction * move_time;
    }

	// apply water friction
    if (ent.waterlevel && !(ent.moveflags & MF_ONLADDER))
        drop += speed * phys_waterfriction * ent.waterlevel * move_time;
	
	// scale the velocity
    newspeed = speed - drop;
    if (newspeed < 0)
        newspeed = 0;
    newspeed /= speed;

    ent.velocity[0] = ent.velocity[0] * newspeed;
    ent.velocity[1] = ent.velocity[1] * newspeed;
    ent.velocity[2] = ent.velocity[2] * newspeed;
}


/*
=============
PM_AddCurrents
=============
*/
vector PM_AddCurrents(entity ent, vector wishvel)
{
    vector  v;
    float   s;

    //
    // account for ladders
    //

    if ((ent.moveflags & MF_ONLADDER) && fabs(ent.velocity[2]) <= 200) {
        if ((input_angles_x <= -15) && (input_movevalues_x > 0))
            wishvel[2] = 200;
        else if ((input_angles_x >= 15) && (input_movevalues_x > 0))
            wishvel[2] = -200;
        else if (input_movevalues_x > 0)
            wishvel[2] = 200;
        else if (input_movevalues_x < 0)
            wishvel[2] = -200;
        else
            wishvel[2] = 0;

        // limit horizontal speed when on a ladder
        wishvel[0] = bound(-25, wishvel[0], 25);
        wishvel[1] = bound(-25, wishvel[1], 25);
    }
	
	
    //
    // add water currents
    //
    if (FALSE) {//(ent.watertype & MASK_CURRENT) {
		v = 0;
		
		/*
        if (ent.watertype & CONTENTS_CURRENT_0)
            v[0] += 1;
        if (ent.watertype & CONTENTS_CURRENT_90)
            v[1] += 1;
        if (ent.watertype & CONTENTS_CURRENT_180)
            v[0] -= 1;
        if (ent.watertype & CONTENTS_CURRENT_270)
            v[1] -= 1;
        if (ent.watertype & CONTENTS_CURRENT_UP)
            v[2] += 1;
        if (ent.watertype & CONTENTS_CURRENT_DOWN)
            v[2] -= 1;
		*/

        s = 200;
        if ((ent.waterlevel == 1) && (ent.flags & FL_ONGROUND))
            s /= 2;
		
		wishvel += (s * v);
    }

    //
    // add conveyor belt velocities
    //
    if (ent.flags & FL_ONGROUND) {
        v = 0;

		/*
        if (pml.groundcontents & CONTENTS_CURRENT_0)
            v[0] += 1;
        if (pml.groundcontents & CONTENTS_CURRENT_90)
            v[1] += 1;
        if (pml.groundcontents & CONTENTS_CURRENT_180)
            v[0] -= 1;
        if (pml.groundcontents & CONTENTS_CURRENT_270)
            v[1] -= 1;
        if (pml.groundcontents & CONTENTS_CURRENT_UP)
            v[2] += 1;
        if (pml.groundcontents & CONTENTS_CURRENT_DOWN)
            v[2] -= 1;
		*/
		
		wishvel += (100 * v);
    }
	
	return wishvel;
}



/*
===================
PM_WaterMove

===================
*/
void PM_WaterMove(entity ent, float move_time)
{
    int     i;
    vector  wishvel;
    float   wishspeed;
    vector  wishdir;

//
// user intentions
//
	
	vector move_corrected = normalize([input_movevalues_x, input_movevalues_y, 0]);
    float fmove = move_corrected_x * fabs(input_movevalues_x) * MAXSPEED;
    float smove = move_corrected_y * fabs(input_movevalues_y) * MAXSPEED;
	float umove = input_movevalues_z * MAXSPEED;
	
	wishvel = (v_forward * fmove) + (v_right * smove);

    if (!fmove && !smove && !umove)
        wishvel[2] -= 60;       // drift towards bottom
    else
        wishvel[2] += umove;

    //PM_AddCurrents(wishvel);

    wishdir = normalize(wishvel);
    wishspeed = vlen(wishvel);

    if (wishspeed > MAXSPEED) {
		wishvel *= ((MAXSPEED) / wishspeed);
        wishspeed = (MAXSPEED);
    }
    wishspeed *= MAXSPEED_WATERMULT;

    PM_Accelerate(ent, wishdir, wishspeed, ACCEL_WATER, move_time);

    PM_StepSlideMove(ent, move_time);
}

/*
===================
PM_SpecMove

===================
*/
#define SPEC_MAXSPEED 200
void PM_SpecMove(entity ent, float move_time)
{
    int     i;
    vector  wishvel;
    float   wishspeed;
    vector  wishdir;

//
// user intentions
//
	
	vector move_corrected = normalize([input_movevalues_x, input_movevalues_y, 0]);
    float fmove = move_corrected_x * fabs(input_movevalues_x) * SPEC_MAXSPEED;
    float smove = move_corrected_y * fabs(input_movevalues_y) * SPEC_MAXSPEED;

	wishvel = (v_forward * fmove) + (v_right * smove);
	wishvel[2] += input_movevalues_z * SPEC_MAXSPEED;
	
    //PM_AddCurrents(wishvel);

    wishdir = normalize(wishvel);
    wishspeed = vlen(wishvel);

    if (wishspeed > SPEC_MAXSPEED) {
		wishvel *= ((SPEC_MAXSPEED) / wishspeed);
        wishspeed = (SPEC_MAXSPEED);
    }
	
	setsize(self, '-16 -16 -16', '16 16 16');
	
	ent.flags |= FL_ONGROUND;
	PM_Friction(ent, move_time);
    PM_Accelerate(ent, wishdir, wishspeed, ACCEL, move_time);
    PM_StepSlideMove(ent, move_time);
}


/*
==============
PM_AirMove

Handles movement
==============
*/
void PM_AirMove(entity ent, float move_time)
{
    int         i;
    vector      wishvel;
    float       fmove, smove;
    vector      wishdir;
    float       wishspeed;
    float       maxspeed;
	
	maxspeed = (ent.moveflags & MF_CROUCHED) ? MAXSPEED_CROUCH : MAXSPEED;
	vector move_corrected = normalize([input_movevalues_x, input_movevalues_y, 0]);
    fmove = move_corrected_x * fabs(input_movevalues_x) * maxspeed;
    smove = move_corrected_y * fabs(input_movevalues_y) * maxspeed;
	
	local vector h_ang = input_angles;
	h_ang[0] = 0;
	makevectors(h_ang);
	wishvel = (v_forward * fmove) + (v_right * smove);
	wishvel[2] = 0;
	makevectors(input_angles);
	
	wishvel = PM_AddCurrents(ent, wishvel);
	
	
	
	
	
	wishdir = normalize(wishvel);
    wishspeed = vlen(wishvel);

    if (wishspeed > maxspeed) {
        wishvel = wishvel * (maxspeed / wishspeed);
        wishspeed = maxspeed;
    }

    if (ent.moveflags & MF_ONLADDER) {
        PM_Accelerate(ent, wishdir, wishspeed, ACCEL, move_time);
        if (!wishvel[2]) {
            if (ent.velocity[2] > 0) {
                ent.velocity[2] -= ent.gravity * phys_gravity * move_time;
                if (ent.velocity[2] < 0)
                    ent.velocity[2] = 0;
            } else {
                ent.velocity[2] += ent.gravity * phys_gravity * move_time;
                if (ent.velocity[2] > 0)
                    ent.velocity[2] = 0;
            }
        }
        PM_StepSlideMove(ent, move_time);
    } else if (ent.flags & FL_ONGROUND) {
        // walking on ground
        ent.velocity[2] = 0; //!!! this is before the accel
        PM_Accelerate(ent, wishdir, wishspeed, ACCEL, move_time);
		ent.velocity[2] -= ent.gravity * phys_gravity * move_time;
		
        if (!ent.velocity[0] && !ent.velocity[1])
            return;
        PM_StepSlideMove(ent, move_time);
    } else {
        // not on ground, so little effect on velocity
        PM_Accelerate(ent, wishdir, wishspeed, 1, move_time);
        // add gravity
        ent.velocity[2] -= ent.gravity * phys_gravity * move_time;
        PM_StepSlideMove(ent, move_time);
    }
}


/*
=============
PM_CheckSpecialMovement
=============
*/
void PM_CheckSpecialMovement(entity ent)
{
    vector  spot;
    int     cont;
    vector  flatforward;
    trace_t trace;

    if (ent.client_time < ent.land_time)
		return;
	
	ent.moveflags -= (ent.moveflags & MF_ONLADDER);
	
    // check for ladder
    flatforward[0] = v_forward[0];
    flatforward[1] = v_forward[1];
    flatforward[2] = 0;
    flatforward = normalize(flatforward);
	
	spot = ent.origin + (1 * flatforward);
    tracebox_full(&trace, ent.origin, ent.mins, ent.maxs, spot, MOVE_NORMAL, ent);
    if ((trace.fraction < 1) && (trace.endcontents & 0x20000000))
	{
		ent.moveflags |= MF_ONLADDER;
	}

    // check for water jump
    if (ent.waterlevel != 2)
        return;
	
	spot = ent.origin + (30 * flatforward);
    spot[2] += 4;
    cont = pointcontents(spot);
    if (!(cont == CONTENT_SOLID))
        return;
	
    spot[2] += 16;
    cont = pointcontents(spot);
    if (cont == CONTENT_SOLID)
        return;
    // jump out of water
	ent.velocity = flatforward * 50;
    ent.velocity[2] = 350;
	
    ent.land_time = ent.client_time + 0.2;
}

/*
=============
PM_CategorizePosition
=============
*/
void PM_CategorizePosition(entity ent)
{
    vector      point;
    int         cont;
    trace_t     trace;
    int         sample1;
    int         sample2;

// if the player hull point one unit down is solid, the player
// is on ground

// see if standing on something solid
    point[0] = ent.origin[0];
    point[1] = ent.origin[1];
    point[2] = ent.origin[2] - 0.25f;
    if (ent.velocity[2] > 180) {
        ent.flags &= ~FL_ONGROUND;
        ent.groundentity = world;
    } else {
        tracebox_full(&trace, ent.origin, ent.mins, ent.maxs, point, MOVE_NORMAL, ent);
        //ent.groundplane = trace.plane;
        //ent.groundsurface = trace.surface;
        //ent.groundcontents = trace.contents;

        if (trace.fraction == 1 || (trace.plane_normal[2] < 0.7f && !trace.startsolid)) {
            ent.groundentity = world;
			ent.groundplane = trace.plane_normal;
            ent.flags &= ~FL_ONGROUND;
        } else {
            ent.groundentity = trace.ent;

            // hitting solid ground will end a waterjump
			/*
			if (pm->s.pm_flags & PMF_TIME_WATERJUMP) {
                pm->s.pm_flags &= ~(PMF_TIME_WATERJUMP | PMF_TIME_LAND | PMF_TIME_TELEPORT);
                pm->s.pm_time = 0;
            }
			*/

            if (!(ent.flags & FL_ONGROUND)) {
                // just hit the ground
                ent.flags |= FL_ONGROUND;
				ent.land_time = ent.client_time + 0.025;
                // don't do landing time if we were just going down a slope
				if (ent.velocity[2] < -200) {
                    // don't allow another jump for a little while
                    if (ent.velocity[2] < -400)
                        ent.land_time = ent.client_time + 0.025;
                    else
                        ent.land_time = ent.client_time + 0.018;
                }
            }
        }

        if (ent.numtouch < MAXTOUCH && trace.ent) {
            ent.touchents[ent.numtouch] = trace.ent;
            ent.numtouch++;
        }
    }

//
// get waterlevel, accounting for ducking
//
    ent.waterlevel = 0;
    ent.watertype = 0;

    sample2 = ent.view_ofs[2] - ent.mins[2];
    sample1 = sample2 / 2;

    point[2] = ent.origin[2] + ent.mins[2] + 1;
    cont = pointcontentsmask(point);
	ent.watertype = cont;
	
    if (cont & CONTENTBITS_FLUID) {
        ent.watertype = cont;
        ent.waterlevel = 1;
        point[2] = ent.origin[2] + ent.mins[2] + sample1;
        cont = pointcontentsmask(point);
        if (cont & CONTENTBITS_FLUID) {
            ent.waterlevel = 2;
            point[2] = ent.origin[2] + ent.mins[2] + sample2;
            cont = pointcontentsmask(point);
            if (cont & CONTENTBITS_FLUID)
                ent.waterlevel = 3;
        }
    }
}


void PM_CheckStairs(entity ent, float move_time)
{
	local float spd = move_time;
	
	if (ent.sview_height < -0.5)
	{
		if (ent.sview_height > -1)
			ent.sview_height = 0;
		else if (ent.sview_height >= -12)
			ent.sview_height += spd * 140;
		else if (ent.sview_height >= -24)
			ent.sview_height += spd * 200;
		else
			ent.sview_height = -23;
		
		ent.sview_height = min(0, ent.sview_height);
	}
	else if (ent.sview_height > 0.5)
	{
		if (ent.sview_height < 1)
			ent.sview_height = 0;
		else if (ent.sview_height <= 12)
			ent.sview_height -= spd * 140;
		else if (ent.sview_height <= 24)
			ent.sview_height -= spd * 200;
		else
			ent.sview_height = 23;
		
		ent.sview_height = max(0, ent.sview_height);
	}
	else
	{
		ent.sview_height = 0;
	}
}


void PM_CheckJump(entity ent)
{
	if (input_movevalues_z <= 0)
	{
		ent.flags |= FL_JUMPRELEASED;
		return;
	}
	
	if (input_movevalues_z < 0)
		return;
	
    if (ent.waterlevel >= 2) {
        // swimming, not jumping
        ent.groundentity = world;

        if (ent.velocity[2] <= -300)
            return;

        // FIXME: makes velocity dependent on client FPS,
        // even causes prediction misses
        if (ent.watertype == CONTENT_WATER)
            ent.velocity[2] = 100;
        else if (ent.watertype == CONTENT_SLIME)
            ent.velocity[2] = 80;
        else
            ent.velocity[2] = 50;
        return;
    }
	
	if (!(ent.flags & FL_ONGROUND))
		return;

	if ( !(ent.flags & FL_JUMPRELEASED) )
		return;
	
	ent.flags -= (ent.flags & FL_JUMPRELEASED);
	ent.flags -= (ent.flags & FL_ONGROUND);
	//input_buttons -= (input_buttons & 2);
	
	local float jvel = 270;
	ent.velocity[2] = max(ent.velocity[2] + jvel, jvel);
	
	#ifdef SSQC
	PL_Sound(ent, CHAN_VOICE, PLSOUND_JUMP, 1, ATTN_VOICE);
	#endif
}

void PM_CheckDuck(entity ent)
{
    trace_t trace;
	
	int old_moveflags = ent.moveflags;
	
	if (!(ent.flags & FL_ONGROUND) || (ent.client_time < ent.land_time))
	{
		ent.moveflags |= MF_BLOCKCROUCH;
	}
	else
	{
		ent.moveflags -= (ent.moveflags & MF_BLOCKCROUCH);
	}
	
    ent.mins[0] = -16;
    ent.mins[1] = -16;

    ent.maxs[0] = 16;
    ent.maxs[1] = 16;

    ent.mins[2] = -24;
	
	if ((input_movevalues_z < 0) && !(input_buttons & 2) && !(ent.moveflags & MF_BLOCKCROUCH)) {
        // duck
        ent.moveflags |= MF_CROUCHED;
    } else {
        // stand up if possible
        if (ent.moveflags & MF_CROUCHED) {
            // try to stand up
            ent.maxs[2] = 32;
            tracebox_full(&trace, ent.origin, ent.mins, ent.maxs, ent.origin, MOVE_NORMAL, ent);
            if (!trace.allsolid)
                ent.moveflags &= ~MF_CROUCHED;
        }
    }

    if (ent.moveflags & MF_CROUCHED) {
        ent.maxs[2] = 4;
        ent.view_ofs[2] = -2;
		
		if !(old_moveflags & MF_CROUCHED)
		{
			ent.sview_height += 20;
		}
    } else {
        ent.maxs[2] = 32;
        ent.view_ofs[2] = 22;
		
		if (old_moveflags & MF_CROUCHED)
		{
			ent.sview_height -= 20;
			ent.land_time = ent.client_time + 0.2;
		}
    }
	
	setsize(self, self.mins, self.maxs);
}

