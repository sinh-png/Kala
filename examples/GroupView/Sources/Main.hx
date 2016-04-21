package;

import kala.Assets;
import kala.Kala;
import kala.input.Mouse;
import kala.objects.Sprite;
import kala.objects.group.Group;
import kala.objects.group.View;

class Main {
	
	public static function main() {
		
		Kala.world.onFirstFrame.add(function(_) {
			
			var group = new BasicGroup();
			Kala.world.add(group);
			
			var view = new View(0, 0, 300, 300);
			view.halign = view.valign = 0.5; // Always center this view on its render target.
			view.setTransformationOrigin(150, 150);
			group.addView(view);
			
			var background = new Sprite(Assets.images.background);
			group.add(background);
			
			group.onPostUpdate.add(function(_, _) {
				// Scale background to fit framebuffer.
				background.scale.x = Kala.width / background.width;
				background.scale.y = Kala.height / background.height;
	
				view.viewPos.x = Mouse.x;
				view.viewPos.y = Mouse.y;
				
				if (Mouse.pressed.LEFT) view.rotation.angle += 1;
				if (Mouse.pressed.RIGHT) view.skew.x += 1;
			});
			
		});
		
		Kala.start();
		
	}
	
}
