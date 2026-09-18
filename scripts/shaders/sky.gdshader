shader_type sky;

void sky() {
	if (AT_CUBEMAP_PASS) {
		COLOR = vec3(0.2, 0.6, 1.0);
	} else {
		COLOR = texture(RADIANCE, EYEDIR).rgb;
	}
}
