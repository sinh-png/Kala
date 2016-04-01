package;

import kala.Kala;
import kala.math.Vec2;
import kala.objects.shapes.Circle;
import kala.objects.shapes.Polygon;
import kala.objects.shapes.Rectangle;

class Main {
	
	public static function main() {
		
		Kala.world.onFirstFrame.add(function(_) {
			
			var circle = new Circle(80);
			circle.position.setXYBetween(0, 0, 800, 600, 20, 50);
			Kala.world.add(circle);
			
			var rect = new Rectangle(200, 160, true, true);
			rect.position.setOrigin(100, 80).setXY(400, 300);
			rect.lineColor.rgb = 0xff0000;
			rect.lineStrenght = 4;
			Kala.world.add(rect);
			
			var polygon = new Polygon([
				new Vec2(0, 0),
				new Vec2(160, 160),
				new Vec2(160, 0)
			], false);
			polygon.position.setOrigin(80, 80).setXYBetween(0, 0, 800, 600, 80, 50);
			polygon.lineOpacity = 1;
			polygon.lineStrenght = 2;
			Kala.world.add(polygon);
			
		});
		
		Kala.start();
		
	}
	
}
