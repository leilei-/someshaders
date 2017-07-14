/*
	scale down for simulating high native lcd resolutions
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

#pragma parameter NATIVE_WIDTH "Native Width" 640.0 1.0 1280.0 1.0
#pragma parameter NATIVE_HEIGHT "Native Height" 480.0 1.0 1024.0 1.0

uniform COMPAT_PRECISION float NATIVE_WIDTH;
uniform COMPAT_PRECISION float NATIVE_HEIGHT;

#define FixedSize vec2(NATIVE_WIDTH, NATIVE_HEIGHT) // destination monitor size?
#define SourceSize vec4(InputSize, 1.0 / InputSize) 
#define outsize vec4(OutputSize, 1.0 / OutputSize)



void main()
{
	int f;
	vec3 pixelblend;

	vec2 texcoord  = vTexCoord;
	vec2 therecoord  = vTexCoord;
	vec2 difsize;
	vec2 difsiz2;

	difsize.x = FixedSize.x / InputSize.x;
	difsize.y = FixedSize.y / InputSize.y;

	difsiz2.x = FixedSize.x / (InputSize.x * 0.5);
	difsiz2.y = FixedSize.y / (InputSize.y * 0.5);

	// Size it down
	therecoord.x = (therecoord.x * difsize.x);
	therecoord.y = (therecoord.y * difsize.y);

	// Align to center
	if (difsize.x > 1.0){

	// TODO: Fix bad math
	therecoord.x += ((InputSize.x - FixedSize.x) * difsize.x) / (FixedSize.x * 3);
	therecoord.y += ((InputSize.y - FixedSize.y) * difsize.y) / (FixedSize.y * 2);

	}
	else
	{
	//TODO: Top left align? NOT bottom left
	}

	vec4 color = texture(Source, texcoord);
        color = texture(Source, therecoord);
   	FragColor = vec4(color);
} 
#endif
