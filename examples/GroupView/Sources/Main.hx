package;

import kala.Kala;
import kala.input.Mouse;
import kala.objects.Sprite;
import kala.objects.group.Group;
import kala.objects.group.View;
import kha.Assets;

class Main {
	
	public static function main() {
		
		Kala.world.onFirstFrame.add(function(_) {
			
			var group = new BasicGroup();
			Kala.world.add(group);
			
			var view = new View(0, 0, 200, 200);
			view.position.setOrigin(100, 100).setXYBetween(0, 0, 800, 600);
			view.rotation.setPivot(100, 100);
			view.skew.setOrigin(100, 100);
			view.viewPos.setOrigin(100, 100);
			group.addView(view);
			
			var background = new Sprite(Assets.images.background);
			group.add(background);
			
			group.onPreUpdate.add(function(_, _) {
				view.viewPos.x = Mouse.x;
				view.viewPos.y = Mouse.y;
				
				if (Mouse.pressed.LEFT) view.rotation.angle += 1;
				if (Mouse.pressed.RIGHT) view.skew.x += 1;
			});
			
		});
		
		Kala.start();
		
	}
	
}
