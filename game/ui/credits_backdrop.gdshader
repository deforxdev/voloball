shader_type canvas_item;

// the credits page's backdrop: two screenshots, each fitted to cover the
// screen, softly blurred and cross-faded, under a veil so the card reads.
// driven by game/ui/credits_page.gd.

uniform sampler2D tex_a : filter_linear, repeat_disable;
uniform sampler2D tex_b : filter_linear, repeat_disable;
uniform float fade : hint_range(0.0, 1.0) = 0.0;   // 0 = all a, 1 = all b
uniform float blur = 0.009;                        // radius, as a fraction of the screen height
uniform vec2 rect_size = vec2(1920.0, 1080.0);
uniform vec2 size_a = vec2(1280.0, 720.0);
uniform vec2 size_b = vec2(1280.0, 720.0);
uniform float zoom_a = 1.0;                        // a slow push-in while it is up
uniform float zoom_b = 1.0;
uniform vec4 veil : source_color = vec4(0.137, 0.169, 0.231, 0.38);

// uv for a picture scaled to COVER the rect (cropped, never stretched)
vec2 cover(vec2 uv, vec2 tex_size, float zoom) {
	float ra = rect_size.x / max(rect_size.y, 1.0);
	float ta = tex_size.x / max(tex_size.y, 1.0);
	vec2 s = vec2(1.0);
	if (ta > ra) {
		s.x = ra / ta;
	} else {
		s.y = ta / ra;
	}
	return (uv - 0.5) * s / zoom + 0.5;
}

// a small disc blur: 20 taps on a golden-angle spiral
vec3 soft(sampler2D t, vec2 uv, vec2 px) {
	vec3 acc = texture(t, uv).rgb;
	for (int i = 1; i <= 20; i++) {
		float f = float(i);
		float r = sqrt(f / 20.0);
		float a = f * 2.39996;
		acc += texture(t, uv + vec2(cos(a), sin(a)) * r * px).rgb;
	}
	return acc / 21.0;
}

void fragment() {
	vec2 px = vec2(blur * rect_size.y / max(rect_size.x, 1.0), blur);
	vec3 a = soft(tex_a, cover(UV, size_a, zoom_a), px);
	vec3 b = soft(tex_b, cover(UV, size_b, zoom_b), px);
	vec3 c = mix(a, b, smoothstep(0.0, 1.0, fade));
	COLOR = vec4(mix(c, veil.rgb, veil.a), 1.0);
}
