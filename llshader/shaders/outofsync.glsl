/*
	Out of sync
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

#pragma parameter MAXRES_WIDTH "Maximum Width" 720.0 4 1600 1.0
#pragma parameter MAXRES_HEIGHT "Maximum Height" 480.0 4 1200 1.0

uniform COMPAT_PRECISION float MAXRES_WIDTH;
uniform COMPAT_PRECISION float MAXRES_HEIGHT;

#define FixedSize vec2(MAXRES_WIDTH, MAXRES_HEIGHT) 
#define SourceSize vec4(InputSize, 1.0 / InputSize) 
#define outsize vec4(OutputSize, 1.0 / OutputSize)



void main()
{
	int f;
	vec3 pixelblend;

	vec2 texcoord  = vTexCoord;
	vec2 difsize;
	vec2 wrong;

	float moving;
	vec4 color = texture(Source, texcoord);

	difsize.x = FixedSize.x - InputSize.x; 
	difsize.y = FixedSize.y - InputSize.y; 

	wrong.x = mod(texcoord.x + (texcoord.y * (difsize.x+difsize.y)), 1.0); // is this wrong?
	moving = (mod(FrameCount, 1024) / InputSize.y) * 60;	// TODO: Replace with proper refresh rate
	wrong.y = mod(texcoord.y + moving, 0.7); // is this wrong?

	if (InputSize.x > FixedSize.x) // uh oh
		color = texture(Source, wrong);	



   	FragColor = vec4(color);
} 
#endif
