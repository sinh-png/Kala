package;

import kala.Kala;
import kala.components.Timer;
import kala.input.Keyboard;
import kala.objects.shapes.Circle;
import kala.objects.shapes.Rectangle;


class Main {
	
	public static function main() {
		
		Kala.world.onFirstFrame.add(function(_) {
			
			var player = new Rectangle(60, 60);
			player.position.setOrigin(30, 30).setXY(300, 300);
			Kala.world.add(player);
			
			var timer = new Timer().addTo(player);
			
			player.onPreUpdate.add(function(_, _) {
				if (Keyboard.pressed.LEFT) player.x -= 4;
				if (Keyboard.pressed.RIGHT) player.x += 4;
				if (Keyboard.pressed.UP) player.y -= 4;
				if (Keyboard.pressed.DOWN) player.y += 4;
				
				if (Keyboard.pressed.Z) {
					timer.cooldown(1, 15, function() {
						// We create new bullet with inlined callback and destroy them when out of screen
						// only for the sake of simplicity. In a real project, we should pool them using 
						// pool.ObjectPool to avoid memory leak.
						var bullet = new Rectangle(30, 5);
						Kala.world.add(bullet);
						
						bullet.position.copy(player.position);
						
						bullet.onPostUpdate.add(function(_, _) {
							bullet.x += 15;
							if (bullet.x > 800) bullet.destroy();
						});
					});
				}
			});
			
			var circle = new Circle(40);
			circle.position.setXY(500, 300);
			circle.scale.x = 2;
			Kala.world.add(circle);
			
			timer.loop(60, 0, true, function(loopTask) {
				circle.rotation.angle = 36 * loopTask.elapsedExecutions;
			});
		});
		
		Kala.start(); 
		
	}
	
}
