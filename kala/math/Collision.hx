package kala.math;

import kala.math.Vec2;
import kala.util.types.Pair;
import kha.FastFloat;

class Collision {
	
	public inline static function pointVsRect(
		pointX:FastFloat, pointY:FastFloat,
		rectX:FastFloat, rectY:FastFloat,
		rectWidth:FastFloat, rectHeight:FastFloat
	):Bool {
		return (
			pointX >= rectX && rectX < rectX + rectWidth &&
			pointY >= rectY && rectY < rectY + rectHeight
		);
	}
	
	public static function pointVsCircle(
		pointX:FastFloat, pointY:FastFloat,
		circleX:FastFloat, circleY:FastFloat, circleRadius:FastFloat
	):Bool {
		var dx = pointX - circleX;
		var dy = pointY - circleY;
		return dx * dx + dy * dy <= circleRadius * circleRadius;
	}

	public static function pointVsPolygon(
		pointX:FastFloat, pointY:FastFloat,
		vertices:Array<Vec2>
	):Bool {
		var angle:FastFloat = 0;
		var p1 = new Vec2();
		var p2 = new Vec2();
		
		for (i in 0...vertices.length) {
			p1.x = vertices[i].x - pointX;
			p1.y = vertices[i].y - pointY;
			p2.x = vertices[(i + 1) % vertices.length].x - pointX;
			p2.y = vertices[(i + 1) % vertices.length].y - pointY;
			angle += p1.angle(p2);
		}

		if (Math.abs(angle) < Math.PI) return false;
		
		return true;
	}
	
	/**
	 * Test two axis-aligned rectangles without getting collision data.
	 */
	public static inline function fastRectVsRect(
		x1:FastFloat, y1:FastFloat, w1:FastFloat, h1:FastFloat,
		x2:FastFloat, y2:FastFloat, w2:FastFloat, h2:FastFloat
	):Bool {
		return (
			x1 < x2 + w2 && x1 + w1 > x2 &&
			y1 < y2 + h2 && y1 + h1 > y2
		);
	}
	
	/**
	 * Test a circle with an axis-aligned rectangle without getting collision data.
	 */
	public static inline function fastCircleVsRect(
		circleX:FastFloat, circleY:FastFloat, circleRadius:FastFloat,
		rectX:FastFloat, rectY:FastFloat, rectWidth:FastFloat, rectHeight:FastFloat
	):Bool {
		var dx = circleX - Mathf.clamp(circleX, rectX, rectX + rectWidth);
		var dy = circleY - Mathf.clamp(circleY, rectY, rectY + rectHeight);
		return dx * dx + dy * dy < circleRadius * circleRadius;
	}
	
	/**
	 * Test two circles without getting collision data.
	 */
	public static inline function fastCircleVsCircle(
		circleAX:FastFloat, circleAY:FastFloat, circleARadius:FastFloat,
		circleBX:FastFloat, circleBY:FastFloat, circleBRadius:FastFloat
	):Bool {
		var totalRadius = circleARadius + circleBRadius;
		return (
			(circleAX - circleBX) * (circleAX - circleBX) + (circleAY - circleBY) * (circleAY - circleBY) <
			totalRadius * totalRadius
		);
	}
	
	// The codes below are copied and modified from: 
	// https://github.com/underscorediscovery/differ/blob/master/differ/sat/SAT2D.hx
	
    public static function circleVsPolygon(
		circleX:FastFloat, circleY:FastFloat, circleRadius:FastFloat,
		vertices:Array<Vec2>
	):CollisionData {
		
        var ep:FastFloat = 0.0000000001;
        var test1:FastFloat; //numbers for testing max/mins
        var test2:FastFloat;
        var test:FastFloat;

        var min1:FastFloat = 0; //same as above
        var max1:FastFloat = 0x3FFFFFFF;
        var min2:FastFloat = 0;
        var max2:FastFloat = 0x3FFFFFFF;
        var normalAxis:Vec2 = new Vec2();
        var offset:FastFloat;
        var vectorOffset:Vec2 = new Vec2();
		
        var shortestDistance:FastFloat = 0x3FFFFFFF;
        var distMin:FastFloat;

        var distance:FastFloat = 0xFFFFFFFF;
        var testDistance:FastFloat = 0x3FFFFFFF;
        var closestVec2:Vec2 = new Vec2(); //the Vec2 to use to find the normal

		var resultAxis:Vec2 = null;
		var resultOverlapAmount:FastFloat = 0;
		
        // find offset
        vectorOffset = new Vec2(-circleX,-circleY);
        vertices = vertices.copy();

        //adds some padding to make it more accurate
        if(vertices.length == 2) {
            var temp:Vec2 = new Vec2(-(vertices[1].y - vertices[0].y), vertices[1].x - vertices[0].x);
            temp.truncate(ep);
            vertices.push(vertices[1].add(temp));
        }

        // find the closest vertex to use to find normal
        for (i in 0 ... vertices.length) {
            distance =  (circleX - (vertices[i].x)) * (circleX - (vertices[i].x)) +
                        (circleY - (vertices[i].y)) * (circleY - (vertices[i].y));

            if(distance < testDistance) { //closest has the lowest distance
                testDistance = distance;
                closestVec2.x = vertices[i].x;
                closestVec2.y = vertices[i].y;
            }
        } //for

        //get the normal Vec2
        normalAxis = new Vec2(closestVec2.x - circleX, closestVec2.y - circleY);
        normalAxis.normalize(); //normalize is(set its length to 1)

        // project the polygon's points
        min1 = normalAxis.dot(vertices[0]);
        max1 = min1; //set max and min

        for(j in 1 ... vertices.length) { //project all its points, starting with the first(the 0th was done up there^)
            test = normalAxis.dot(vertices[j]); //dot to project
            if(test < min1) {
                min1 = test;
            } //smallest min is wanted
            if(test > max1) {
                max1 = test;
            } //largest max is wanted
        }

        // project the circle
        max2 = circleRadius; //max is radius
        min2 -= circleRadius; //min is negative radius

        // offset the polygon's max/min
        offset = normalAxis.dot(vectorOffset);
        min1 += offset;
        max1 += offset;

        // do the big test
        test1 = min1 - max2;
        test2 = min2 - max1;

        if(test1 > 0 || test2 > 0) { //if either test is greater than 0, there is a gap, we can give up now.
            return null;
        }

            // circle distance check
        distMin = -(max2 - min1);
        if(Math.abs(distMin) < shortestDistance) {
            resultAxis = normalAxis;
            resultOverlapAmount = distMin;
            shortestDistance = Math.abs(distMin);
        }

            // find the normal axis for each point and project
        for(i in 0 ... vertices.length) {
            normalAxis = findNormalAxis(vertices, i);

            // project the polygon(again? yes, circles vs. polygon require more testing...)
            min1 = normalAxis.dot(vertices[0]); //project
            max1 = min1; //set max and min

            //project all the other points(see, cirlces v. polygons use lots of this...)
            for(j in 1 ... vertices.length) {
                test = normalAxis.dot(vertices[j]); //more projection
                if(test < min1) {
                    min1 = test;
                } //smallest min
                if(test > max1) {
                    max1 = test;
                } //largest max
            }

            // project the circle(again)
            max2 = circleRadius; //max is radius
            min2 = -circleRadius; //min is negative radius

            //offset points
            offset = normalAxis.dot(vectorOffset);
            min1 += offset;
            max1 += offset;

            // do the test, again
            test1 = min1 - max2;
            test2 = min2 - max1;

                //failed.. quit now
            if(test1 > 0 || test2 > 0) return null;

            distMin = -(max2 - min1);
            if(Math.abs(distMin) < shortestDistance) {
                resultAxis = normalAxis;
                resultOverlapAmount = distMin;
                shortestDistance = Math.abs(distMin);
            }

        } //for

        //if you made it here, there is a collision!!!!!
        return new CollisionData(resultAxis, resultOverlapAmount,
			new Vec2( -resultAxis.x * resultOverlapAmount,
                      -resultAxis.y * resultOverlapAmount ) // the separation distance
		);

    } //testCircleVsPolygon

    public static function circleVsCircle(
		circleAX:FastFloat, circleAY:FastFloat, circleARadius:FastFloat,
		circleBX:FastFloat, circleBY:FastFloat, circleBRadius:FastFloat
	):CollisionData {
        //

            //add both radii together to get the colliding distance
        var totalRadius = circleARadius + circleBRadius;
            //find the distance between the two circles using Pythagorean theorem. No square roots for optimization
        var distancesq = (circleAX - circleBX) * (circleAX - circleBX) + (circleAY - circleBY) * (circleAY - circleBY);

            //if your distance is less than the totalRadius square(because distance is squared)
        if(distancesq < totalRadius * totalRadius) {

                //find the difference. Square roots are needed here.
            var difference:FastFloat = totalRadius - Math.sqrt(distancesq);

			var axis = new Vec2(circleAX - circleBX, circleAY - circleBY);
			axis.normalize();

				//find the movement needed to separate the circles
			var separation = new Vec2(axis.x * difference, axis.y * difference );

				//the magnitude of the overlap
			var overlapAmount = separation.length;

            return new CollisionData(axis, overlapAmount, separation);
        } //if distanceSq

        return null;

    } //testCircleVsCircle

    public static function polygonVsPolygon(
		vertices1:Array<Vec2>, vertices2:Array<Vec2>
	):Pair<CollisionData, Bool> {

        var result1 = checkPolygons(vertices1, vertices2);

        if(result1 == null) return null;

        var result2 = checkPolygons(vertices2, vertices1);

        if (result2 == null) return null;

            //take the closest overlap
		if (Math.abs(result1.overlapAmount) < Math.abs(result2.overlapAmount)) {
			return new Pair<CollisionData, Bool>(result1, false);
		}
	
        return new Pair<CollisionData, Bool>(result2.flip(), true);
    } //testPolygonVsPolygon

        /** Internal api - test a ray against a circle */
	public static function rayVsCircle(
		rayStart:Vec2, rayEnd:Vec2, rayInfinite:Bool,
		circleX:FastFloat, circleY:FastFloat, circleRadius:FastFloat
	):Pair<FastFloat, FastFloat> {

        var delta = rayEnd.sub(rayStart);
        var ray2circle = rayStart.sub(new Vec2(circleX, circleY));

        var a = delta.x * delta.x + delta.y * delta.y;
        var b = 2 * delta.dot(ray2circle);
        var c = ray2circle.dot(ray2circle) - circleRadius * circleRadius;

        var d:FastFloat = b * b - 4 * a * c;

        if (d >= 0) {
            d = Math.sqrt(d);

            var t1:FastFloat = (-b - d) / (2 * a);
            var t2:FastFloat = (-b + d) / (2 * a);

            if (rayInfinite || t1 <= 1.0) {
                return new Pair<FastFloat, FastFloat>(t1, t2);
            }
        } //d>=0

        return null;
    } //testRayVsCircle

        /** Internal api - test a ray against a polygon */
	public static function rayVsPolygon(
		rayStart:Vec2, rayEnd:Vec2, rayInfinite:Bool,
		vertices:Array<Vec2>
	):Pair<FastFloat, FastFloat> {

        var delta = rayEnd.sub(rayStart);
        vertices = vertices.copy();

        var min_u:FastFloat = Math.POSITIVE_INFINITY;
        var max_u:FastFloat = 0.0;

        if (vertices.length > 2) {

            var v1 = vertices[vertices.length - 1];
            var v2 = vertices[0];

            var r = intersectRayRay(rayStart, delta, v1, v2.sub(v1));

            if (r != null && r.b >= 0.0 && r.b <= 1.0) {
                if (r.a < min_u) min_u = r.a;
                if (r.a > max_u) max_u = r.a;
            }

            for (i in 1...vertices.length) {
                v1 = vertices[i - 1];
                v2 = vertices[i];

                r = intersectRayRay(rayStart, delta, v1, v2.sub(v1));

                if (r != null && r.b >= 0.0 && r.b <= 1.0) {
                    if (r.a < min_u) min_u = r.a;
                    if (r.a > max_u) max_u = r.a;
                }
            } //each vert

            if(rayInfinite || min_u <= 1.0) {
                return new Pair<FastFloat, FastFloat>(min_u, max_u);
            }

        } //vert length > 2

        return null;
    } //testRayVsPolygon

        /** Internal api - test a ray against another ray */
	public static function rayVsRay(
		rayAStart:Vec2, rayAEnd:Vec2, rayAInfinite:Bool,
		rayBStart:Vec2, rayBEnd:Vec2, rayBInfinite:Bool
	):Pair<FastFloat, FastFloat> {

        var delta1 = rayAEnd.sub(rayAStart);
        var delta2 = rayBEnd.sub(rayBStart);

        var dx = rayAStart.sub(rayBStart);

        var d = delta2.y * delta1.x - delta2.x * delta1.y;

        if (d == 0.0) return null;

        var u1 = (delta2.x * dx.y - delta2.y * dx.x) / d;
        var u2 = (delta1.x * dx.y - delta1.y * dx.x) / d;

        if ((rayAInfinite || u1 <= 1.0) && (rayBInfinite || u2 <= 1.0)) {
			return new Pair<FastFloat, FastFloat>(u1, u2);
		}

        return null;
    } //testRayVsRay

//Helpers

        /** Internal api - generate a bresenham line between given start and end points */
	public static function bresenhamLine(start:Vec2, end:Vec2):Array<Vec2> {
            //the array of all the points on the line
        var points:Array<Vec2> = [];
        var steep:Bool = Math.abs(end.y - start.y) > Math.abs(end.x - start.x);
            //check if rise is greater than run
        var swapped:Bool = false;

            //reflect the line
        if(steep) {
            start = swap(start);
            end = swap(end);
        } //if steep

             //make sure the line goes downward
        if(start.x > end.x) {

            var t:FastFloat = start.x;

            start.x = end.x;
            end.x = t;
            t = start.y;
            start.y = end.y;
            end.y = t;
            swapped = true;

        } //if start.x > end.x

            //x slope
        var deltax:FastFloat = end.x - start.x;
            //y slope, positive because the lines always go  down
        var deltay:FastFloat = Math.abs(end.y - start.y);
            //error is used instead of tracking the y values.
        var error:FastFloat = deltax / 2;
        var ystep:FastFloat;
        var y:FastFloat = start.y;

        if(start.y < end.y) {
            ystep = 1;
        } else {
            ystep = -1;
        }
		
        var x:Int = Std.int(start.x);
        for(x in Std.int(start.x) ... Std.int(end.x)) { //for each point

            if(steep) {
                points.push(new Vec2(y, x)); //if its steep, push flipped version
            } else {
                points.push(new Vec2(x, y)); //push normal
            }

            error -= deltay; //change the error

            if(error < 0) {
                y += ystep; //if the error is too much, adjust the ystep
                error += deltax;
            }
        }

        if(swapped) {
            points.reverse();
        }

        return points;
    } //bresenhamLine

//Internal helpers

        /** Internal api - implementation details for testPolygonVsPolygon */
    static function checkPolygons(
		vertices1:Array<Vec2>, vertices2:Array<Vec2>
	):CollisionData {
		
        var ep:FastFloat = 0.0000000001;
        var test1:FastFloat; // numbers to use to test for overlap
        var test2:FastFloat;
        var testNum:FastFloat; // number to test if its the new max/min
        var min1:FastFloat; //current smallest(shape 1)
        var max1:FastFloat; //current largest(shape 1)
        var min2:FastFloat; //current smallest(shape 2)
        var max2:FastFloat; //current largest(shape 2)
        var axis:Vec2; //the normal axis for projection
        var offset:FastFloat;
		
        var shortestDistance:FastFloat = 0x3FFFFFFF;

		var resultAxis:Vec2 = null;
		var resultOverlapAmount:FastFloat = 0;
		
        vertices1 = vertices1.copy();
        vertices2 = vertices2.copy();

            // add a little padding to make the test work correctly for lines
        if(vertices1.length == 2) {
            var temp = new Vec2(-(vertices1[1].y - vertices1[0].y), vertices1[1].x - vertices1[0].x);
            temp.truncate(ep);
            vertices1.push(vertices1[1].add(temp));
        }

        if(vertices2.length == 2) {
            var temp = new Vec2(-(vertices2[1].y - vertices2[0].y), vertices2[1].x - vertices2[0].x);
            temp.truncate(ep);
            vertices2.push(vertices2[1].add(temp));
        }

            // loop to begin projection
        for(i in 0 ... vertices1.length) {

                // get the normal axis, and begin projection
            axis = findNormalAxis(vertices1, i);

                // project polygon1
            min1 = axis.dot(vertices1[0]);
            max1 = min1; //set max and min equal

            for(j in 1 ... vertices1.length) {
                testNum = axis.dot(vertices1[j]); //project each point
                if(testNum < min1) {
                    min1 = testNum;
                } //test for new smallest
                if(testNum > max1) {
                    max1 = testNum;
                } //test for new largest
            }

            // project polygon2
            min2 = axis.dot(vertices2[0]);
            max2 = min2; //set 2's max and min

            for(j in 1 ... vertices2.length) {
                testNum = axis.dot(vertices2[j]); //project the point
                if(testNum < min2) {
                    min2 = testNum;
                } //test for new min
                if(testNum > max2) {
                    max2 = testNum;
                } //test for new max
            }

            // and test if they are touching
            test1 = min1 - max2; //test min1 and max2
            test2 = min2 - max1; //test min2 and max1
            if(test1 > 0 || test2 > 0) { //if they are greater than 0, there is a gap
                return null; //just quit
            }

            var distMin:FastFloat = -(max2 - min1);
            if(Math.abs(distMin) < shortestDistance) {
                resultAxis = axis;
                resultOverlapAmount = distMin;
                shortestDistance = Math.abs(distMin);
            }
        }

        //if you're here, there is a collision

        return new CollisionData(
			resultAxis, resultOverlapAmount, 
			new Vec2(-resultAxis.x * resultOverlapAmount, -resultAxis.y * resultOverlapAmount) //return the separation, apply it to a polygon to separate the two shapes.
		);
    } //checkPolygons

        /** Internal api - swap x and y of a Vec2, returning a new Vec2. :todo: this is silly */
	static inline function swap(v:Vec2):Vec2 return new Vec2(v.y, v.x);

        /** Internal api - same thing as rayRay, except without using Ray objects - saves the construction of a Ray object when testing Polygon/Ray. */
	static function intersectRayRay(a:Vec2, adelta:Vec2, b:Vec2, bdelta:Vec2):Pair<FastFloat, FastFloat> {

        var dx = a.sub(b);

        var d = bdelta.y * adelta.x - bdelta.x * adelta.y;

        if (d == 0.0) return null;

        var ua = (bdelta.x * dx.y - bdelta.y * dx.x) / d;
        var ub = (adelta.x * dx.y - adelta.y * dx.x) / d;

        return new Pair<FastFloat, FastFloat>(ua, ub);
    } //intersectRayRay
	
	static function findNormalAxis(vertices:Array<Vec2>, index:Int):Vec2 {
		var vec1 = vertices[index];
		var vec2 = (index >= vertices.length - 1) ? vertices[0] : vertices[index + 1];
		var normalAxis = new Vec2( -(vec2.y - vec1.y), vec2.x - vec1.x);
		return normalAxis.normalize();
	}

}


class CollisionData {

	public var axis:Vec2;
	public var overlapAmount:FastFloat;
	public var separation:Vec2;
	
	public inline function new(axis:Vec2, overlapAmount:FastFloat, separation:Vec2) {
		this.axis = axis;
		this.overlapAmount = overlapAmount;
		this.separation = separation;
	}
	
	@:extern
	public inline function flip():CollisionData {
		axis.invert();
		separation.invert();
		overlapAmount = -overlapAmount;
		
		return this;
	}
	
}