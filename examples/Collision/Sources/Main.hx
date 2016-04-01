package;

import kala.Kala;
import kala.components.collision.Collider;
import kala.input.Mouse;
import kala.math.Vec2;
import kala.objects.group.Group.BasicGroup;
import kala.objects.shapes.Circle;
import kala.objects.shapes.Polygon;
import kala.objects.shapes.Rectangle;

class Main {
	
	public static function main() {
		
		Kala.world.onFirstFrame.add(function(_) {
			
			var rect1 = new Rectangle(200, 100, false, true);
			rect1.position.setOrigin(100, 50).setXYBetween(0, 0, 800, 600);
			rect1.skew.setOrigin(100, 50).x = 50;
			Kala.world.add(rect1);
			
			var collider1 = new Collider().addTo(rect1);
			var colRect = collider1.addRect(0, 0, 200, 100);

			var group = new BasicGroup(true);
			group.color.alpha = 1;
			Kala.world.add(group);
			
			var circle = new Circle(80, false, true);
			circle.scale.y = 0.5;
			circle.lineStrenght = 2;
			group.add(circle);
			
			var rect2 = new Rectangle(160, 80, false, true);
			rect2.position.setOrigin(80, 40).setXY( -160, 0);
			rect2.lineStrenght = 2;
			group.add(rect2);
			
			var vertices = [
				new Vec2(0, 0),
				new Vec2(0, 80),
				new Vec2(160, 0)
			];
			var polygon = new Polygon(vertices, false, true);
			polygon.position.setOrigin(80, 40).setXY(160, 0);
			polygon.lineStrenght = 2;
			group.add(polygon);
			
			var collider2 = new Collider().addTo(group);
			
			collider2.addCircle(0, 0, circle.radius).scale.y = circle.scale.y;
			
			collider2.addRect(rect2.x, 0, rect2.width, rect2.height)
			.position.setOrigin(rect2.position.ox, rect2.position.oy);
			
			collider2.addPolygon(polygon.x, 0, vertices)[0]
			.position.setOrigin(polygon.position.ox, polygon.position.oy);
			
			group.onPostUpdate.add(function(_, _) {
				group.x = Mouse.x;
				group.y = Mouse.y;
				
				group.rotation.angle += 2;
		
				if (collider1.test(collider2) != null) {
					rect1.lineColor.rgb = 0xff0000;
					group.color.rgb = 0xff0000;
				} else {
					rect1.lineColor.rgb = 0xffffff;
					group.color.rgb = 0xffffff;
				}
			});

		});
		
		Kala.start();
		
	}
	
}
