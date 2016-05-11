package;

import kala.input.Keyboard;
import kala.input.Mouse;
import kala.Kala;
import kala.math.color.BlendMode;
import kala.math.Vec2;
import kala.objects.group.Group.GenericGroup;
import kala.objects.shapes.Circle;
import kala.objects.shapes.Polygon;
import kala.objects.shapes.Rectangle;

class Main {
	
	public static function main() {
		
		Kala.world.onFirstFrame.notify(function(_) {
			
			// GenericGroup is a typedef of Group<Object>
			var group = new GenericGroup(true);
			group.antialiasing = true;
			group.colorBlendMode = BlendMode.SUB; // How the group color will be blended with its children colors.
			Kala.world.add(group);
			
			group.onPostUpdate.notify(function(_, _) {
				group.x = Mouse.x;
				group.y = Mouse.y;
				
				if (Mouse.LEFT.pressed) 	group.skew.x += 1;
				if (Mouse.pressed.RIGHT) 	group.scale.y += 0.01;
				
				if (Keyboard.pressed.SPACE) group.rotation.angle += 5;
				
				if (Keyboard.pressed.CTRL) 	group.color.red = group.color.red - 5;
			});
			
			var circle = new Circle(80);
			group.add(circle);
			
			var rect = new Rectangle(200, 160);
			rect.position.set( -200, 0, 100, 80);
			group.add(rect);
			
			var polygon = new Polygon([
				new Vec2(0, 0),
				new Vec2(160, 160),
				new Vec2(160, 0)
			]);
			polygon.position.setXY(100, -80);
			group.add(polygon);
			
		});
		
		Kala.start();
		
	}
	
}
