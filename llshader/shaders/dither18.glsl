/*
	Dither
    Authors: leilei
 
    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the Free
    Software Foundation; either version 2 of the License, or (at your option)
    any later version.
*/


// leilei - Dither to 18-bit color (262122 colors)
//		

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


float dithertable[16] = {
	16,4,13,1,   
	8,12,5,9,
	14,2,15,3,
	6,10,7,11		
};


#define BPP 64

void main()
{
	float blue;
	
	vec2 texcoord  = vTexCoord;
	vec2 texcoord2  = vTexCoord;
	texcoord2.x *= TextureSize.x;
	texcoord2.y *= TextureSize.y;
	vec4 reduce = vec4(64,64,64,64);
	vec4 color = texture(Source, texcoord);


	// Dithery
	int ditdex = 	int(mod(texcoord2.x, 4.0)) * 4 + int(mod(texcoord2.y, 4.0)); // 4x4!
	int yeh = 0;
	float ohyes;	// Dithered texture

	for (yeh=ditdex; yeh<(ditdex+16); yeh++) 	ohyes =  (((dithertable[yeh-15]) - 1)) / (BPP/6);


	// Reduce to 18bpp

	color.r = pow(color.r, 1.0);
	color.g = pow(color.g, 1.0);
	color.b = pow(color.b, 1.0);

	color.r *= BPP;
	color.g *= BPP;
	color.b *= BPP;

	color.r += ohyes;
	color.g += ohyes;
	color.b += ohyes;


	color.r = floor(color.r);
	color.g = floor(color.g);
	color.b = floor(color.b);

	color.r /= BPP;
	color.g /= BPP;
	color.b /= BPP;

	color.r = pow(color.r, 1.0);
	color.g = pow(color.g, 1.0);
	color.b = pow(color.b, 1.0);


   	FragColor = vec4(color);
} 
#endif
