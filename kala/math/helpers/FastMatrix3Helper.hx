package kala.math.helpers;

import kha.math.FastMatrix3;

class FastMatrix3Helper {

	public static inline function clone(source:FastMatrix3 ):FastMatrix3 {
		return new FastMatrix3(
			source._00, source._10, source._20,
			source._01, source._11, source._21,
			source._02, source._12, source._22
		);
	}
	
}