shader_type canvas_item;

uniform sampler2D crystal_back;
uniform sampler2D noise;

void fragment(){
	vec2 iResolution = vec2(1.0 / SCREEN_PIXEL_SIZE);
	vec2 uv = FRAGCOORD.xy / iResolution;
	
	//float thresh = fract(TIME * 0.1);
	float thresh = 0.6;
	
    vec4 back = texture(TEXTURE, UV);
	vec4 sparkle = texture(crystal_back, (UV / TEXTURE_PIXEL_SIZE) / 32.0);
	sparkle = texture(crystal_back, sparkle.xy + SCREEN_UV);
	
	//vec4 sparklemap = textureLod(noise, (UV / TEXTURE_PIXEL_SIZE) / 16.0, 0.0);
	//sparklemap = textureLod(noise, sparklemap.xy + SCREEN_UV + TIME * 0.001, 0.0) - 0.5;
		
    //float sparks = pow(clamp((dot(vec3(0.0, 0.0, 1), normalize(sparklemap.xyz))), 0.0, 1.0),30.0);
    
    //COLOR = mix(back, clamp(sparkle + 0.05 * back + sparks, 0.0, 1.0), 0.8);
	float my_col = vec4(step(sparkle.r, thresh)).r;
	my_col *= 1.0 - step(sparkle.r, thresh - 0.2);
	
	float my_col2 = vec4(step(sparkle.r, thresh +0.2)).r;
	my_col2 *= 1.0 - step(sparkle.r, thresh - 0.8);
	
	vec4 col = back + vec4(my_col, 0.1, my_col, 1.0);
	vec4 col2 = back + vec4(my_col2 * 0.5, 0.1, my_col2 * 0.8, 1.0);
	//my_col = sparkle;
	COLOR = mix(col, col2, 0.5);
}