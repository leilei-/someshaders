/*
		crappy signal associated with certain video cards, especially 
	the one	that knocked out the oen that flew close to the sun

    Authors: leilei
 
    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the Free
    Software Foundation; either version 2 of the License, or (at your option)
    any later version.
*/


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
#define FixedSize vec2(1280, 960)
#define SourceSize vec4(FixedSize, 1.0 / FixedSize) // Doing fixed size allows it to make it worse on higher resolutions
#define outsize vec4(OutputSize, 1.0 / OutputSize)

void main()
{
	int f;
	vec3 pixelblend;

	vec2 texcoord  = vTexCoord;
	vec4 color = texture(Source, texcoord);

	for(f=1;f<4;f++)
	{
	vec3 pixel1 = texture(Source, texcoord + vec2((-0.0032f / 4) * f + (0.00128f / 4), 0)).rgb;
	
	pixelblend.r += pixel1.r;
	pixelblend.g += pixel1.g;
	pixelblend.b += pixel1.b;
	}

	pixelblend.rgb /= f;

	pixelblend.rgb = (pixelblend.rgb * 0.333f) + (color.rgb * 0.666f);

	vec2 whoopsr = { 0.0004, 0.0 };
	vec2 whoopsg = { 0.0, 0.0 };
	vec2 whoopsb = { -0.0004, 0.0001 };


	vec4 colorr = texture(Source, texcoord + whoopsr);
	vec4 colorg = texture(Source, texcoord + whoopsg);
	vec4 colorb = texture(Source, texcoord + whoopsb);

	color.r = pixelblend.r;
	color.g = pixelblend.g;
	color.b = pixelblend.b;

   	FragColor = vec4(color);
} 
#endif
