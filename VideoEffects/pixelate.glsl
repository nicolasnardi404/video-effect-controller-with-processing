#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D textureSampler;
uniform float amount; // 0.0 to 1.0
uniform vec2 resolution;

void main() {
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    float pixels = 100.0 * (1.0 - amount) + 5.0; // More amount = fewer pixels
    vec2 pixelated = floor(uv * pixels) / pixels;
    gl_FragColor = texture2D(textureSampler, pixelated);
} 