shader_type canvas_item;

uniform vec2 position[6];
uniform float times[6];
uniform float ripple_speed = 1.0;
uniform float ripple_width = 0.2;

void fragment()
{
	vec2 uv = UV;
	float distortion = 0.0;
	
	for (int i = 0; i < 6; i++)
	{
		float dist = distance(uv, position[i]);
		float radius = times[i] * ripple_speed;
		
		float circle = smoothstep(radius - ripple_width, radius, dist) -
						smoothstep(radius, radius + ripple_width, dist);
		distortion += circle * 0.1;
	}	
	COLOR = texture(TEXTURE, uv + distortion);

}