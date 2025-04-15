#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D textureSampler;
uniform float amount;
uniform float time;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
    vec2 uv = vertTexCoord.xy;
    
    // Create time-based offset with more pronounced effect
    float shift = amount * 0.05 * (1.0 + sin(time * 2.0));
    
    // Sample the texture with RGB channel separation
    vec4 color;
    color.r = texture2D(textureSampler, vec2(uv.x + shift, uv.y)).r;
    color.g = texture2D(textureSampler, uv).g;
    color.b = texture2D(textureSampler, vec2(uv.x - shift, uv.y)).b;
    color.a = 1.0;
    
    // Add some vertical glitch lines
    float glitchLine = step(0.98, sin(uv.y * 100.0 + time * 10.0));
    vec2 glitchOffset = vec2(shift * 2.0 * glitchLine, 0.0);
    vec4 glitchColor = texture2D(textureSampler, uv + glitchOffset);
    
    // Mix between normal and glitched color
    gl_FragColor = mix(color, glitchColor, glitchLine * amount);
} 