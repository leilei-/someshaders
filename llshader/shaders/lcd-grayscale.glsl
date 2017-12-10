/*
	Early laptop screens
    Authors: leilei
 
    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the Free
    Software Foundation; either version 2 of the License, or (at your option)
    any later version.
*/


// leilei - quick hacky greyscale for laptops

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
#define FixedSize vec2(640, 480)
#define SourceSize vec4(FixedSize, 1.0 / FixedSize) //either TextureSize or InputSize
#define outsize vec4(OutputSize, 1.0 / OutputSize)


void main()
{
	vec2 texcoord  = vTexCoord;
	vec4 color = texture(Source, texcoord);
	float intensity = ((color.r * 0.30) + (color.g*0.59) + (color.b*0.11));

	vec4 back;
	vec4 backd;
	vec4 front;
	vec4 mid;


// Backlight / "black"
	back.r = 0.12;
	back.g = 0.14;
	back.b = 0.18;

	backd.r = 0.39;
	backd.g = 0.46;
	backd.b = 0.52;

	mid.r = 0.59;
	mid.g = 0.68;
	mid.b = 0.73;

	front.r = 0.70;
	front.g = 0.79;
	front.b = 0.82;

// New algorithm

	float ratio = 1 - ( (intensity*255) / 255 );

	float inv1 = ratio * 3.0;
	float inv2 = ratio * 3.0 - 1;
	float inv3 = ratio * 3.0 - 2;
	float inv4 = ratio * 3.0 - 3;

	if (inv1 > 1.0f) inv1 = 1.0f;
	if (inv2 > 1.0f) inv2 = 1.0f;
	if (inv3 > 1.0f) inv3 = 1.0f;
	if (inv4 > 1.0f) inv4 = 1.0f;

	if (ratio < 0.33f){
			color.r = (mid.r * inv1) + (front.r * (1 - inv1));
			color.g = (mid.g * inv1) + (front.g * (1 - inv1));
			color.b = (mid.b * inv1) + (front.b * (1 - inv1));
		}

	else if (ratio < 0.66f){
			color.r = (backd.r * inv2) + (mid.r * (1 - inv2));
			color.g = (backd.g * inv2) + (mid.g * (1 - inv2));
			color.b = (backd.b * inv2) + (mid.b * (1 - inv2));
		}
	else {
			color.r = (back.r * inv3) + (backd.r * (1 - inv3));
			color.g = (back.g * inv3) + (backd.g * (1 - inv3));
			color.b = (back.b * inv3) + (backd.b * (1 - inv3));
		}

// Shadows
	int f;
	float pxshadow;
	for(f=1;f<4;f++)
	{
	vec3 pixel1 = texture(Source, texcoord + vec2((-0.002f / 4) * f, (0.004f / 4) * f)).rgb;
	float intenshadow = ((pixel1.r * 0.30) + (pixel1.g*0.59) + (pixel1.b*0.11)) / 48;
	pxshadow += intenshadow;

	}

   	FragColor = vec4(color) - pxshadow;
} 
#endif
