package;
import kala.math.color.Color;

import kala.Kala;
import kala.input.Keyboard;
import kala.input.Mouse;
import kala.math.color.Color.ColorBlendMode;
import kala.math.Vec2;
import kala.objects.group.Group.BasicGroup;
import kala.objects.shapes.Circle;
import kala.objects.shapes.Polygon;
import kala.objects.shapes.Rectangle;

class Main {
	
	public static function main() {
		
		Kala.world.onFirstFrame.add(function(_) {
			
			// BasicGroup is just a typedef of Group<Object>
			var group = new BasicGroup(true);
			group.antialiasing = true;
			group.color.alpha = 1;
			group.colorBlendMode = ColorBlendMode.NORMAL; // How the group color will be blended with its children colors.
			Kala.world.add(group);
			
			group.onPostUpdate.add(function(_, _) {
				group.x = Mouse.x;
				group.y = Mouse.y;
				
				if (Mouse.pressed.LEFT) group.skew.x += 1;
				if (Mouse.pressed.RIGHT) group.scale.y += 0.01;
				
				if (Keyboard.pressed.SPACE) group.rotation.angle += 5;
				
				if (Keyboard.pressed.CTRL)
					group.color.setRGBComponents(0, group.color.green() - 5, 0);
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
