#version 460 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;

const float sunPathRotation = -40.0f;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);
}