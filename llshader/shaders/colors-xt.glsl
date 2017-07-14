/*
	CRT Colors hack
    Authors: leilei
 
    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the Free
    Software Foundation; either version 2 of the License, or (at your option)
    any later version.
*/
// leilei - try to boost blue
//		imitating the look of a certain rgbi monitor from 1983


#define HW 1.00

#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying 
#define COMPAT_ATTRIBUTE attribute 
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;
// out variables go here as COMPAT_VARYING whatever

vec4 _oPosition1; 
uniform mat4 MVPMatrix;
uniform int FrameDirection;
uniform int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

void main()
{
    gl_Position = MVPMatrix * VertexCoord;
    COL0 = COLOR;
    TEX0.xy = TexCoord.xy;
// Paste vertex contents here:

}

#elif defined(FRAGMENT)

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform int FrameDirection;
uniform int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;

// compatibility #defines
#define Source Texture
#define vTexCoord TEX0.xy
#define texture(c, d) COMPAT_TEXTURE(c, d)
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define outsize vec4(OutputSize, 1.0 / OutputSize)

void main()
{
	vec2 texcoord  = vTexCoord;

	vec4 color = texture(Source, texcoord);
	vec4 colorb = texture(Source, texcoord);
	vec3 pollute;
	float sat;

	pollute.r = 0.7;
	pollute.g = 0.8;
	pollute.b = 1.0;

	sat = (color.r + color.g + color.b) / 3;

	float blbst;
	float bothrg;
	float avg;
	float blgamma = 1.9;
	float rggamma = 0.6;

	colorb.r *= pollute.r;
	colorb.g *= pollute.g;
	colorb.b *= pollute.b;



	// Gammafy

	colorb.r = pow(colorb.r, 1.0 / blgamma);
	colorb.g = pow(colorb.g, 1.0 / blgamma);
	colorb.b = pow(colorb.b, 1.0 / blgamma);

	// Brightify

	//colorb.rg -= (colorb.b * 0.01);
	colorb.rgb += (colorb.b * 0.24);
	colorb.rgb *= 1;


   	FragColor = vec4(colorb);
} 
#endif
