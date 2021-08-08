
float DEG2RAD = 0.0174532925199432957692369076848861271344287188854172545609719144;
float RAD2DEG = 57.2957795130823208767981548141051703324054724665643215491602438612;
float PI      = 3.1415926535897932384626433832795028841971693993751058209749445923;

#if defined(SSQC) || defined(CSQC)
typedef struct trace_t {
    float    	allsolid;   // if true, plane is not valid
    float    	startsolid; // if true, the initial point was in a solid area
    float       fraction;   // time completed, 1.0 = didn't hit anything
    vector      endpos;     // final position
    vector    	plane_normal;      // surface normal at impact
	float		plane_dist;
    int         contents;   // contents on other side of surface hit
	entity		ent;
	float		inopen;
	float		inwater;
	int			endcontents;
	int			surfaceflags;
};

void traceline_full(trace_t *trace, vector v1, vector v2, float move, entity ignore)
{
	traceline(v1, v2, move, ignore);
	
	trace.allsolid = trace_allsolid;
	trace.startsolid = trace_startsolid;
	trace.fraction = trace_fraction;
	trace.endpos = trace_endpos;
	trace.plane_normal = trace_plane_normal;
	trace.plane_dist = trace_plane_dist;
	trace.ent = trace_ent;
	trace.inopen = trace_inopen;
	trace.inwater = trace_inwater;
	trace.endcontents = trace_endcontentsi;
	trace.surfaceflags = trace_surfaceflagsi;
}

void tracebox_full(trace_t *trace, vector v1, vector mins, vector maxs, vector v2, float move, entity ignore)
{
	tracebox(v1, mins, maxs, v2, move, ignore);
	
	trace.allsolid = trace_allsolid;
	trace.startsolid = trace_startsolid;
	trace.fraction = trace_fraction;
	trace.endpos = trace_endpos;
	trace.plane_normal = trace_plane_normal;
	trace.plane_dist = trace_plane_dist;
	trace.ent = trace_ent;
	trace.inopen = trace_inopen;
	trace.inwater = trace_inwater;
	trace.endcontents = trace_endcontentsi;
	trace.surfaceflags = trace_surfaceflagsi;
}
#endif



#if defined(SSQC) || defined(CSQC)
int isLiquid(int cont) {
	if (cont == CONTENT_WATER || cont == CONTENT_SLIME || cont == CONTENT_LAVA) {
		return TRUE;
	} else {
		return FALSE;
	}
}
#endif

void SUB_Null()
{
	
}

float crandom()
{
	return (random() - 0.5) * 2;
}

vector(vector surfnorm, vector vec) vector_project =
{
	float v;
	v = vec*surfnorm;
	return vec - surfnorm*(v);
}

float round(float x)
{
	if (x - floor(x) >= 0.5)
		return ceil(x);
	else
		return floor(x);
}

/*
vector CrossProduct(vector a, vector b)
{
	vector c;

	c_x = a_y * b_z - a_z * b_y;
	c_y = a_z * b_x - a_x * b_z;
	c_z = a_x * b_y - a_y * b_x;

	return c;
}
*/

#define CrossProduct(v1,v2,cross) \
        ((cross)[0]=(v1)[1]*(v2)[2]-(v1)[2]*(v2)[1], \
         (cross)[1]=(v1)[2]*(v2)[0]-(v1)[0]*(v2)[2], \
         (cross)[2]=(v1)[0]*(v2)[1]-(v1)[1]*(v2)[0])

float DotProduct(vector a, vector b)
{
	return ((a)[0] * (b)[0] + (a)[1] * (b)[1] + (a)[2] * (b)[2]);
}

vector VectorMA(vector a, float scale, vector b, vector c)
{
	c[0] = a[0] + (scale * b[0]);
	c[1] = a[1] + (scale * b[1]);
	c[2] = a[2] + (scale * b[2]);
	
	return c;
}

float Log2n(float n) 
{ 
    return (n > 1) ? 1 + Log2n(n / 2) : 0; 
} 

float lerp(float x0, float x1, float t)
{
    return x0 + t*(x1-x0);
}

float (float x, float y) angle_difference =
{
	local float a;
	a = x - y;
	a = (a + 180) % 360 - 180;
	if (a > 180) a -= 360;
	if (a < -180) a += 360;
	
	return a;
}


// Returns position of the only set bit in 'n' 
float powerofTwo(float n) 
{ 
    return n && (!(n & (n - 1))); 
} 

float findPosition(float n) 
{
    if !(powerofTwo(n))
	{
		return 0;
	}
	
	float i = 1;
	float pos = 0;
	
	
    while (!(i & n)) { 
        // shift over to next bit, inserting a 0 in its place
        i = i << 1; 
  
        // increment return value by 1
        pos++; 
    } 
  
    return pos; 
} 