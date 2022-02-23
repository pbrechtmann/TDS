// HSV to RBG from https://www.rapidtables.com/convert/color/hsv-to-rgb.html
shader_type canvas_item;

uniform float strength: hint_range(0., 1.) = 0.5;
uniform float speed: hint_range(0., 10.) = 0.5;
uniform float angle: hint_range(0., 360.) = 0.;

uniform vec4 overlay_color: hint_color;

float when_less_than(float x, float y) {
  return max(sign(y - x), 0.0);
}

void fragment() {
	float hue = UV.x * cos(radians(angle)) - UV.y * sin(radians(angle));
	hue = fract(hue + fract(TIME  * speed));
	float x = 1. - abs(mod(hue / (1./ 6.), 2.) - 1.);
	vec4 overlay = overlay_color * when_less_than(hue, 0.5);
	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, vec4(overlay.rgb, color.a), strength);
}
