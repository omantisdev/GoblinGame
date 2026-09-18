shader_type canvas_item;

// A needed global uniform to get the position of the effector
global uniform vec2 object_position;

// Mask with RGB channels used to divide in three deformation sections 
// (one for each channel)
uniform sampler2D deform_mask_texture;

// Strength of the deform
uniform float deform_strength = 0.25;

varying vec2 pivot_world_pos;
varying vec3 deform_map_strength;

void vertex() {
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE

	// Obtain pivot point of texture
	pivot_world_pos = MODEL_MATRIX[3].xy;

	// Divide the deform sections in three
	deform_map_strength.x = distance(
		(pivot_world_pos - vec2(texture_size.x/6.0, 0.0)), 
		object_position) * 0.07
	deform_map_strength.y = distance(pivot_world_pos, object_position) * 0.007;
	deform_map_strength.z = distance((pivot_world_pos + vec2(texture_size.x/6.0, 0.0)), object_position) * 0.007;

	deform_map_strength = clamp(deform_map_strength, 0.0, 1.0);	
	deform_map_strength = deform_map_strength / 2.0 + 0.5;
	deform_map_strength = 1.0 - deform_map_strength;

	VERTEX.y += length(deform_map_strength) * texture_size.y * deform_strength * 0.32;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;

	// Get the deform mask texture
	vec3 deform_mask = texture(deform_mask_texture, UV).rgb

	// Offset horizontaly so each section responnds accordingly to the position
	uv.y -= deform_mask.r * deform_strength * deform_map_strength.x;
	uv.y -= deform_mask.g * deform_strength * deform_map_strength.y;
	uv.y -= deform_mask.b * deform_strength * deform_map_strength.z;

	// Retexture the deformation done on the fragment shader
	COLOR = texture(TEXTURE, uv);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
