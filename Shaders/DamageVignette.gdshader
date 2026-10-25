shader_type canvas_item;

// Exposed parameters
uniform vec4 vignetteColor : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Default to Red
uniform float strength : hint_range(0.0, 1.0) = 0.0; // 0.0 = Hidden, 1.0 = Max Red

void fragment() {
    // Center the UV coordinates (-1.0 to 1.0)
    vec2 uv = UV * 2.0 - 1.0;
    float distance_from_center = length(uv);
    
    // Dynamically calculate the radius and softness based on strength
    // As strength goes up, the vignette creeps closer to the center
    float radius = mix(1.5, 0.4, strength); 
    float softness = mix(0.8, 0.3, strength);
    
    // Calculate vignette shape
    float vignette = smoothstep(radius, radius - softness, distance_from_center);
    
    // Scale the final alpha transparency by the strength
    float finalAlpha = (1.0 - vignette) * strength * vignetteColor.a;
    
    COLOR = vec4(vignetteColor.rgb, finalAlpha);
}
