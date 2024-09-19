#version 460

// ATTRIBUTES
in vec3 vaPosition;
in vec2 vaUV0;
in vec4 vaColor;
in ivec2 vaUV2;
in vec3 vaNormal;

// UNIFORMS
uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 modelViewMatrixInverse;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

// OUTS
out vec2 texCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;
out vec3 geometryNormal;
out float blockLightLevel;
out vec3 viewSpacePosition;

void main(){

    geometryNormal = normalMatrix*vaNormal;

    vec4 viewSpacePosition4 = modelViewMatrix * vec4(position,1.0);
    viewSpacePosition = viewSpacePosition4.xyz;

    texCoord = vaUV0;
    foliageColor = vaColor.rgb;
    lightMapCoords = vaUV2 * (1.0/256.0) + (1.0/32.0);

    gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition+chunkOffset,1);
}