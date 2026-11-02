// SHARED by beach_crowd.gdshader (the people) and beach_crowd_shadow.gdshader (their
// blob shadows): where a person is right now and how far they're knocked over, so
// a shadow can never drift from its person. game/court/beach_crowd_field.gd mirrors
// the walker maths on the CPU (to find who a player walked into) -- keep them equal.
//
// (both shaders write POSITION themselves and are fog_disabled: the engine's fog
// runs VERTEX through MODEL_MATRIX, and the data-carrying basis below made it see
// everyone a kilometre away and fog them solid. the people haze themselves instead)
// per instance, from the MultiMesh (see beach_crowd_field.gd):
//   MODEL_MATRIX[3].xyz  where they stand (a walker's x and y; z is moved here)
//   MODEL_MATRIX[0].x    knock time on crowd_time (-1000 = never knocked)
//   MODEL_MATRIX[0].y    seconds a walker has spent knocked down (holds it back)
//   MODEL_MATRIX[2].xz   which way they were pushed
//   INSTANCE_CUSTOM      x person, y phase, z facing / TAU, w kind (0 stand, 1 sit, 2 walk)

uniform float crowd_time = 0.0;        // the crowd's own clock (pauses with the game)
uniform vec2 walk_z = vec2(-150.0, 150.0);
uniform float walk_speed = 1.3;        // metres a second
uniform float knock_total = 4.0;       // seconds from the push to standing again
uniform float knock_fall = 0.3;        // seconds to go down
uniform float knock_rise = 0.8;        // seconds to get back up

float crowd_knock_age(mat4 m) {
	return crowd_time - m[0].x;
}

// 0 standing .. 1 flat on the ground
float crowd_down(mat4 m) {
	float age = crowd_knock_age(m);
	if (age < 0.0 || age > knock_total) {
		return 0.0;
	}
	float fall = smoothstep(0.0, knock_fall, age);
	float rise = 1.0 - smoothstep(knock_total - knock_rise, knock_total, age);
	return min(fall, rise);
}

// a walker's place on its lane: it stops while knocked down, and picks up where it
// left off (its lost seconds ride MODEL_MATRIX[0].y)
vec3 crowd_origin(mat4 m, vec4 cd) {
	vec3 o = m[3].xyz;
	if (cd.w > 1.5) {
		float age = crowd_knock_age(m);
		float clock = (age >= 0.0 && age < knock_total) ? m[0].x : crowd_time;
		float span = walk_z.y - walk_z.x;
		float dir = cos(cd.z * 6.2831853) >= 0.0 ? 1.0 : -1.0;
		float t = cd.y * span + (clock - m[0].y) * walk_speed * dir;
		o.z = walk_z.x + mod(t, span);
	}
	return o;
}
