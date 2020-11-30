shader_type canvas_item;

uniform vec4 blink_color : hint_color;
uniform float blink_magnitude = 1.0;

void fragment(){
	vec4 og_color = texture(TEXTURE, UV);
	vec4 col = og_color * MODULATE;
	vec4 blink_stuff = blink_color * og_color.a;
	col = mix(col, blink_stuff, blink_magnitude);
	COLOR = col;
}