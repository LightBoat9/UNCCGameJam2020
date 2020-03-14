shader_type canvas_item;

uniform bool active = false;
uniform float percentage = 0.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec4 per = (vec4(1.0, 1.0, 1.0, 1.0) - col) * percentage;
	per.a = 1.0;
	
	if (active && col.a > 0.0) {
		vec4 add = col + per;
		add.a = 1.0;
		COLOR = add;
	}
	else {
		COLOR = col;
	}
}