shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled;
uniform vec2 grid = vec2(46.0, 7.0);
uniform vec4 tape_color : source_color = vec4(0.97, 0.97, 0.95, 1.0);
uniform vec4 cord_color : source_color = vec4(0.04, 0.04, 0.04, 1.0);
uniform float wobble = 0.0;
uniform float sag = 0.34;
void vertex() {
	VERTEX.y -= sin(UV.x * 3.14159) * sag;
}
void fragment() {
	vec2 cells = UV * grid;
	vec2 cell = fract(cells);
	vec2 width = max(vec2(0.06), fwidth(cells) * 0.65);
	bool tape = UV.y < 0.055 || UV.y > 0.965 || UV.x < 0.005 || UV.x > 0.995;
	if (!tape && cell.x > width.x && cell.y > width.y) { discard; }
	ALBEDO = tape ? tape_color.rgb : cord_color.rgb;
}
