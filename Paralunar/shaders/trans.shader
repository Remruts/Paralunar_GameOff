shader_type canvas_item;
uniform float threshold = 0.0;
uniform float tile_scale = 0.75;
uniform vec2 mov_speed = vec2(0.5, 0.5);
// Taken from the shader book:
// https://thebookofshaders.com/09/

vec2 rotate2D(vec2 _st, float _angle){
    _st -= 0.5;
    _st = mat2(
		vec2(cos(_angle),-sin(_angle)),
		vec2(sin(_angle),cos(_angle))) * _st;
    _st += 0.5;
    return _st;
}

vec2 tile(vec2 _st, float _zoom){
    _st *= _zoom;
    return fract(_st);
}

float box(vec2 _st, vec2 _size, float _smoothEdges){
    _size = vec2(0.5)-_size*0.5;
    vec2 aa = vec2(_smoothEdges*0.5);
    vec2 uv = smoothstep(_size,_size+aa,_st);
    uv *= smoothstep(_size,_size+aa,vec2(1.0)-_st);
    return uv.x*uv.y;
}

void fragment(){
	float PI = 3.14159265358979323846;
	
	vec2 st = UV;//vec2(0.1, 0.1); //FRAGCOORD.xy / SCREEN_PIXEL_SIZE;
	st = tile(st, tile_scale);	
	st = rotate2D(st,PI*0.25);
	
	float bx = box(st,vec2(threshold),0.01);
	vec4 col = texture(TEXTURE, UV + mov_speed * TIME);
	col.a = bx;
	col.rgb *= col.a;
	//float left = step(0.1,st.x);
    //float bottom = step(0.1,st.y);

    // The multiplication of left*bottom will be similar to the logical AND.
    //col = vec3( left * bottom );
	
	COLOR = col;
}