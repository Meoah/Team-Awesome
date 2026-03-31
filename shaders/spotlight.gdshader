shader_type canvas_item;

uniform vec2 hole_uv = vec2(0.5, 0.5);
uniform float radius = 0.12;
uniform float feather = 0.02;

void fragment() {
	vec4 col = COLOR;

	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;

	vec2 hu = clamp(hole_uv, vec2(0.0), vec2(1.0));
	vec2 p = UV - hu;
	p.x *= aspect;

	float d = length(p);

	float r = max(radius, 0.0);
	float f = max(feather, 0.0001);
	float mask = smoothstep(r, r + f, d);

	col.a *= mask;
	COLOR = col;
}