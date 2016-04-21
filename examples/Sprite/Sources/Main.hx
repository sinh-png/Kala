package;

import kala.Kala;
import kala.components.SpriteAnimation;
import kala.objects.Sprite;
import kha.Assets;

class Main {
	
	public static function main() {
		
		Kala.world.onFirstFrame.add(function(_) {
			
			// A sprite with no animation.
			var staticSprite = new Sprite(Assets.images.sprite_sheet, 0, 0, 137, 110);
			Kala.world.add(staticSprite);
			
			// A sprite that will be added with animation.
			var animatedSprite = new Sprite(Assets.images.sprite_sheet, 0, 0, 137, 110);
			animatedSprite.x = staticSprite.width;
			
			// SpriteAnimation is a component which does just what its name suggests.
			// After creating the component, we add it to the sprite.
			var animation = new SpriteAnimation().addTo(animatedSprite);
			// Add an animation then play it. Function comments for more info.
			animation.addAnim("normal", null, -1, -1, 0, 0, 3, 3, 6).play();
			
			Kala.world.add(animatedSprite);
			
		});
		
		Kala.start();
		
	}
	
}
