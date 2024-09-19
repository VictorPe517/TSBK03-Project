#version 460

#define TONEMAPPING 1.0// Tonemapping, remaps the colors to be more filmic [0.0 1.0]
#define EXPOSURE 1.0 // Camera exposure multiplier [0.5 0.75 1.0 1.5 2.0 3.0 4.0]
#define CURVE_EXPONENT 1.0 // Tonemapping curve exponent [0.5 0.75 1.0 1.5 2.0 3.0 4.0]
#define CURVE_MIDTONE 0.5 // Tonemapping divisor coefficient [0.1 0.33 0.5 0.66 0.75 0.9 1.0 1.25]

// UNIFORMS
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;
uniform ivec2 eyeBrightness;
uniform vec3 cameraPosition;

/* DRAWBUFFERS:0*/
layout(location=0)out vec4 outColor0;


// ATTRIBUTES
in vec2 texCoord;
in vec3 foliageColor;
in vec2 lightMapCoords;
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

    vec4 outputColorData = (texture(gtexture,texCoord));
    float transparency = outputColorData.a;
    if(transparency<.1){
        discard;
    }

    
    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse)*shadowLightPosition);
    vec3 worldGeoNormal = normalize(mat3(gbufferModelViewInverse) * geometryNormal);
    
    vec4 blockLightColor = (texture2D(lightmap,vec2(lightMapCoords.x,-1.0)));


    float worldLightBrightness = 1.0*clamp(dot(shadowLightDirection,worldGeoNormal),0.1,1.0);
    float blockLightIntensity = clamp((blockLightColor.r + blockLightColor.g + blockLightColor.b)/3.0,0.5,1.0)-0.5;
    vec3 theFoilageColor = (foliageColor);
    

    vec3 r = reflect(-shadowLightDirection,worldGeoNormal);
    vec3 v = normalize(cameraPosition);
    float specular = dot(r,v);
	if (specular > 0.0)
		specular = 200 * pow(specular, 150.0);
	specular = max(specular, 0.0);
	float shade = 0.7*worldLightBrightness + 1.0*specular;
    
    vec3 outputColor = outputColorData.rgb * theFoilageColor * (1.5*blockLightIntensity+1.5*worldLightBrightness);
    outColor0=vec4(outputColor,transparency);
}