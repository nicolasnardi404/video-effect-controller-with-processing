#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D textureSampler;
uniform float amount; // 0.0 to 1.0
uniform float time;
uniform vec2 resolution;

void main() {
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    
    // Create wave distortion
    float wave1 = sin(uv.y * 10.0 + time) * amount * 0.05;
    float wave2 = cos(uv.x * 8.0 + time * 1.2) * amount * 0.05;
    
    vec2 distortedUV = uv + vec2(wave1, wave2);
    gl_FragColor = texture2D(textureSampler, distortedUV);
} 