#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D textureSampler;
uniform float amount;
uniform float time;

varying vec4 vertColor;
varying vec4 vertTexCoord;

// Random and noise functions
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void main() {
    vec2 uv = vertTexCoord.xy;
    vec4 texColor = texture2D(textureSampler, uv);
    
    // Create dynamic noise pattern
    float noiseValue = noise(uv * 10.0 + time);
    
    // Create scanlines
    float scanline = sin(uv.y * 800.0) * 0.5 + 0.5;
    
    // Create digital noise blocks
    vec2 blockPos = floor(uv * 32.0);
    float blockNoise = random(blockPos + floor(time * 8.0));
    
    // Create glitch blocks
    float glitchNoise = step(0.95, random(vec2(time * 10.0, floor(uv.y * 20.0))));
    vec2 glitchOffset = vec2(glitchNoise * amount * 0.1, 0.0);
    
    // Mix different noise types
    float noiseFinal = mix(noiseValue, blockNoise, 0.5) * amount;
    
    // Apply color shifting and distortion
    vec4 shiftedColor = texColor;
    shiftedColor.r = texture2D(textureSampler, uv + glitchOffset + vec2(noiseFinal * 0.02, 0.0)).r;
    shiftedColor.b = texture2D(textureSampler, uv - glitchOffset - vec2(noiseFinal * 0.02, 0.0)).b;
    
    // Final color
    vec4 finalColor = mix(texColor, shiftedColor, amount);
    finalColor.rgb *= mix(1.0, mix(1.0, noiseValue, 0.3) * mix(1.0, blockNoise, 0.3), amount);
    finalColor.rgb *= mix(1.0, scanline, amount * 0.3);
    
    gl_FragColor = finalColor;
} 