
entity 	player_localentity;
vector 	scrsz;
float	view_fov;

float	prediction_effectframe;
float	prediction_playeffects;
int 	prediction_thinktrigger;

float	is_spectator;
float	cmd_forceimpulse;

.float	lerp_time;
.float	lerp_stepsize;
.float	skin_shader;

.vector	vdmg_angles;
.vector	vdmg_last;
.vector	vdmg_current;
.float	vdmg_time;
.float	vdmg_lerptime;

const int FONT_HUD = 1;






void draw_radial(vector position, float rad_in, float rad_out, float start, float end, float step, vector rgb, float alph, float drawflag)
{
	if (start > end || step < 0)
		return;

	start *= DEG2RAD;
	end *= DEG2RAD;
	step *= DEG2RAD;

	local float ij  = start;

	local vector ps0 = position + [cos(ij) * rad_in, sin(ij) * rad_in];
	local vector ps1 = position + [cos(ij) * rad_out, sin(ij) * rad_out];
	local vector ps2;
	local vector ps3;

	while (ij < end)
	{
		local float ik = min(ij + step, end);
		ps2 = position + [cos(ik) * rad_in, sin(ik) * rad_in];
		ps3 = position + [cos(ik) * rad_out, sin(ik) * rad_out];

		ij = ik;

		R_BeginPolygon("", drawflag, TRUE);
			R_PolygonVertex(ps0, '0 0', rgb * 0.8, alph * 0.7);


			R_PolygonVertex(ps1, '1 0', rgb, alph);


			R_PolygonVertex(ps3, '1 1', rgb, alph);


			R_PolygonVertex(ps2, '0 1', rgb * 0.8, alph * 0.7);
		R_EndPolygon();

		ps0 = ps2;
		ps1 = ps3;
	}
}

void(vector org, vector size, vector clr, float alpha, string tex, float dflags) drawbillboard {
	makevectors(view_angles);
	size *= 0.5;
	local vector tl = org + (v_up * size_y) + (v_right * -size_x);
	local vector tr = org + (v_up * size_y) + (v_right * size_x);
	local vector bl = org + (v_up * -size_y) + (v_right * -size_x);
	local vector br = org + (v_up * -size_y) + (v_right * size_x);
	
	
	R_BeginPolygon(tex, dflags);
	R_PolygonVertex(bl, [0, 1], clr, alpha);
	R_PolygonVertex(tl, [0, 0], clr, alpha);
	R_PolygonVertex(tr, [1, 0], clr, alpha);
	R_EndPolygon();
	
	R_BeginPolygon(tex, dflags);
	R_PolygonVertex(tr, [1, 0], clr, alpha);
	R_PolygonVertex(br, [1, 1], clr, alpha);
	R_PolygonVertex(bl, [0, 1], clr, alpha);
	R_EndPolygon();
}

void(vector org, vector size, vector clr, float alpha, string tex, float dflags) drawbillboard_nopitch {
	makevectors([view_angles_x * 0.4, view_angles_y, 0]);
	size *= 0.5;
	local vector tl = org + (v_up * size_y) + (v_right * -size_x);
	local vector tr = org + (v_up * size_y) + (v_right * size_x);
	local vector bl = org + (v_up * -size_y) + (v_right * -size_x);
	local vector br = org + (v_up * -size_y) + (v_right * size_x);
	
	
	R_BeginPolygon(tex, dflags);
	R_PolygonVertex(bl, [0, 1], clr, alpha);
	R_PolygonVertex(tl, [0, 0], clr, alpha);
	R_PolygonVertex(tr, [1, 0], clr, alpha);
	R_EndPolygon();
	
	R_BeginPolygon(tex, dflags);
	R_PolygonVertex(tr, [1, 0], clr, alpha);
	R_PolygonVertex(br, [1, 1], clr, alpha);
	R_PolygonVertex(bl, [0, 1], clr, alpha);
	R_EndPolygon();
}














