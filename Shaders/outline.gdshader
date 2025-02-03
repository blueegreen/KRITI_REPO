shader_type canvas_item;

uniform vec4 outer_line_color : source_color = vec4(1.0);
uniform vec4 inner_line_color : source_color = vec4(0.0, 0.0, 1.0, 1.0);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float mask = smoothstep(0.35, 0.46, length(UV - vec2(0.5, 0.5))) * COLOR.a;
	//vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV - 5000.*screen_offset);
	vec4 line_color = mix(inner_line_color, outer_line_color, smoothstep(0.47, 0.5, length(UV - vec2(0.5, 0.5))));
	vec2 disp = normalize(UV - vec2(0.5, 0.5)) * 0.03  * mask;
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
	vec3 color = screen_color.rgb + line_color.rgb;
	COLOR = vec4(color, COLOR.a * mask);
	//COLOR = vec4(line_color * mask);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
