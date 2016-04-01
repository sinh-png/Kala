package;

import kala.Kala;
import kala.input.Keyboard;
import kala.input.Mouse;
import kala.objects.shapes.Circle;
import kala.objects.shapes.Rectangle;

class Main {
	
	public static function main() {
		
		Kala.world.onFirstFrame.add(function(_) {
			
			var rect = new Rectangle(200, 100);
			rect.position.setOrigin(100, 50);
		
			// Eac of these transformation has its own origin point.
			// Skewing and rotation angle values are in degrees.
			rect.scale.setOrigin(100, 50);
			rect.skew.set(40, 0, 100, 50);
			rect.rotation.setPivot(100, 50);
			
			Kala.world.add(rect);
		
			rect.onPreUpdate.add(function(_, _) {
				
				// x & y are shortcuts for position.x & position.y
				rect.x = Mouse.x; 
				rect.y = Mouse.y; 
				
				if (Mouse.pressed.LEFT) {
					rect.scale.x = rect.scale.y += 0.01;
				}
				
				if (Mouse.pressed.RIGHT) {
					rect.scale.x = rect.scale.y -= 0.01;
				}
				
				if (Keyboard.justPressed.ANY) {
					rect.rotation.angle += 36;
				}
				
			});
			
		});
		
		Kala.start();
		
	}
	
}
