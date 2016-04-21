package kala.math.color;

import kha.FastFloat;

enum BlendMode {
	
	ALPHA;
	ADD;
	SUB;
	REVERSE_SUB;
	MULTI;
	MULTI_2X;
	SET(src:BlendFactor, dest:BlendFactor, opt:BlendOpt);
	
}

enum BlendOpt {
	
	ADD;
	SUB;
	REVERSE_SUB;
	MAX;
	MIN;
	
}

enum BlendFactor {
	
	ZERO;
	ONE;
	
	SRC_ALPHA;
	INV_SRC_ALPHA;
	
	SRC_COLOR;
	INV_SRC_COLOR;

	DEST_ALPHA;
	INV_DEST_ALPHA;
	
	DEST_COLOR;
	INV_DEST_COLOR;
	
	SRC_ALPHA_SATURATION;
	DEST_ALPHA_SATURATION;
	
	SET(a:FastFloat, r:FastFloat, g:FastFloat, b:FastFloat);
	
}