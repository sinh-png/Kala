Kala is a 2D game engine powered by [Kha](https://github.com/KTXSoftware/Kha). The project is in its very early development and still a proof of concept but you can expect it to grow a lot in a near future.

The examples below will show you some of the implemented features of the engine and how to use them.


#####HELLO WORLD

```haxe
package;

import kala.Kala;
import kala.objects.text.BasicText;
import kha.Assets;

class Main {
	
	public static function main() {
		
		// Kala.world is the root group that contains all other objects. Groups are also a type of object.
		// onFirstFrame is a handle for callbacks that will be executed right before the first update / draw of an object. 
		Kala.world.onFirstFrame.add(function(_) {
			
			// We set a default font that will be used for all text rendering.
			Kala.defaultFont = Assets.fonts.ClearSans_Regular;
			
			var text = new BasicText("HELLO WORLD", 40);
			text.position.setOrigin(text.width / 2, text.height / 2); // Center the original position.
			text.position.setXYBetween(0, 0, 800, 600); // Center the text on screen.
			text.color.rgb = 0x00ffff; // Make it aqua blue because I like the color.  
			Kala.world.add(text); // Add it into the root group.
			
		});
		
		// Does just what you expect.
		Kala.start("Hello!", 800, 600); 
		
	}
	
}

```


#####SPRITE

```haxe
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
```

Using a callback and component based system, Kala aims for:

1. Ease of use.
2. Flexibility.
3. Reusability of code.

