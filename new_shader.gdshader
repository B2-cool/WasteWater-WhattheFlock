shader_type canvas_item;

uniform float scroll_speed = 1.0;
uniform vec2 direction = vec2(1.0, 0.0);

void fragment() {
    vec2 uv = UV;
    uv += TIME * scroll_speed * direction;
    COLOR = texture(TEXTURE, uv);
}