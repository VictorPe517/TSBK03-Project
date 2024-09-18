#version 460

#define TONEMAPPING 1.0// Tonemapping, remaps the colors to be more filmic [0.0 1.0]
#define EXPOSURE 1.0 // Camera exposure multiplier [0.5 0.75 1.0 1.5 2.0 3.0 4.0]
#define CURVE_EXPONENT 1.5 // Tonemapping curve exponent [0.5 0.75 1.0 1.5 2.0 3.0 4.0]
#define CURVE_MIDTONE 1.0 // Tonemapping divisor coefficient [0.1 0.33 0.5 0.66 0.75 0.9 1.0 1.25]

// UNIFORMS
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;

/* DRAWBUFFERS:0*/
layout(location=0)out vec4 outColor0;


// ATTRIBUTES
in vec2 texCoord;
in vec3 foliageColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geometryNormal;

vec3 CorrectGammaVec3(vec3 var){
    return pow(var,vec3(2.2));
}

vec4 CorrectGammaVec4(vec4 var){
    return pow(var,vec4(2.2));
}

vec3 InverseGammaVec3(vec3 var){
    return pow(var,vec3(1.0/2.2));
}

void main(){
    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse)*shadowLightPosition);
    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geometryNormal;

    float worldLightBrightness = 1.0*clamp(dot(shadowLightDirection,worldGeoNormal),0.1,1.0);
    
    vec3 lightColor = (texture(lightmap,lightMapCoords).rgb);
    vec3 theFoilageColor = (foliageColor);
    vec4 outputColorData = (texture(gtexture,texCoord));

    vec3 localLightColor = pow(clamp(lightColor - vec3(worldLightBrightness),0.0,1.0),vec3(3.0));
    
    vec3 outputColor = outputColorData.rgb * theFoilageColor * (1.0*vec3(worldLightBrightness) + 4.0*localLightColor);
    float transparency = outputColorData.a;
    
    if(transparency<.1){
        discard;
    }

    outputColor = outputColor;

    if(TONEMAPPING == 1.0){
        outputColor *= EXPOSURE;
        outputColor = pow(outputColor / (outputColor + CURVE_MIDTONE),vec3(CURVE_EXPONENT));
    }

    outColor0=vec4(outputColor,transparency);
}