shader_type canvas_item;

// A shader by The Gingerjam, I used this page https://godotshaders.com/snippet/random-value/

// Colours
uniform vec4 colour1 : source_color;
uniform vec4 colour2 : source_color;

float random (vec2 uv) {
	// Generate pseudo random value
	return sin(dot(uv.xy,vec2(12, 78))) * 4.5;
}

vec4 lerp_color(float ratio){
	return colour1 / (colour1 + colour2) * clamp(0.0, 1.0, ratio);
}

void fragment(){
	float ratio = UV.x + UV.y + random(UV);
	COLOR = lerp_color(ratio);
}