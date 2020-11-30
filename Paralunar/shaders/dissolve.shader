shader_type canvas_item;

uniform vec4 new_color : hint_color = vec4(0.13, 0.0, 0.32, 0.75);
uniform vec4 inner_color : hint_color = vec4(1.0);
uniform float threshold = 0.5;
uniform sampler2D noise_texture : hint_white;
//uniform vec2 offset = vec2(-3.0, 3.0);
// + vec2(cos(TIME) * UV.x * UV.y, UV.y * UV.x * sin(TIME)) * SCREEN_PIXEL_SIZE * 10.0

void fragment(){
	float thresh = threshold;// * (sin(TIME * 2.0)) / 2.0;
	vec4 col = texture(TEXTURE, UV);
	float noise = texture(noise_texture, 2.0 * vec2(UV.x, UV.y)).r;
	
	float moving_pos = UV.y * noise;
	float noise_thresh = smoothstep(thresh - 0.05, thresh - 0.01, moving_pos);
	float moving_pos2 = UV.y * noise + 0.01;
	float glowing_part = smoothstep(thresh+0.2, thresh-0.1, moving_pos2);
	float glowing_part2 = smoothstep(thresh+0.1, thresh-0.01, moving_pos2);
	
	col.a *= noise_thresh;
	col.rgb *= col.a;
	col.rgb = mix(col.rgb, new_color.rgb * 2.0, glowing_part);	
	col.rgb = mix(col.rgb, inner_color.rgb, glowing_part2);
	COLOR = col;
}