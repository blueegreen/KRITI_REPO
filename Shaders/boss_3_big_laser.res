RSRC                    VisualShader            �(,���Sn                                            3      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame    source    texture    texture_type    script    parameter_name 
   qualifier    color_default    texture_filter    texture_repeat    texture_source 	   function    code    graph_offset    mode    modes/blend    flags/skip_vertex_transform    flags/unshaded    flags/light_only    flags/world_vertex_coords    nodes/vertex/0/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections        &   local://VisualShaderNodeTexture_727y1       1   local://VisualShaderNodeTexture2DParameter_5niml N      %   local://VisualShaderNodeUVFunc_m11yw �      #   res://Shaders/boss_3_big_laser.res �         VisualShaderNodeTexture             	      #   VisualShaderNodeTexture2DParameter    
         laser 	         VisualShaderNodeUVFunc    	         VisualShader          _  shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D laser;



void fragment() {
// UVFunc:4
	vec2 n_in4p1 = vec2(1.00000, 1.00000);
	vec2 n_in4p2 = vec2(0.00000, 0.00000);
	vec2 n_out4p0 = n_in4p2 * n_in4p1 + UV;


	vec4 n_out2p0;
// Texture2D:2
	n_out2p0 = texture(laser, n_out4p0);


// Output:0
	COLOR.rgb = vec3(n_out2p0.xyz);


}
    
   ����׈�                                   
     �B  �B               
     ��  �C             !   
     ��   B"                                                    	      RSRC