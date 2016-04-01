Kala is a component based 2D game engine powered by [Kha](https://github.com/KTXSoftware/Kha). The project is in its very early development and still a proof of concept but you can expect it to grow a lot in the future.

Kala aims for:

1. Ease of use.
2. Flexibility.
3. Reusability of code.

The examples below will show you some of the implemented features of the engine and how to use them.

1. [Hello world](https://github.com/hazagames/Kala#hello-world)
2. [Sprite](https://github.com/hazagames/Kala#sprite)
3. [Shapes](https://github.com/hazagames/Kala#shapes)
4. [Keyboard, mouse input and object transformation](https://github.com/hazagames/Kala#keyboard-mouse-input--object-transformation)
5. [Group transformation](https://github.com/hazagames/Kala#group-transformation)

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

The assets used for this example: https://github.com/hazagames/Kala/tree/master/examples/Sprite/Assets

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


#####SHAPES

*The internal of shape classes are currently only placeholders and going to be rewritten for better performance and functionality.*

```haxe
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
			
			var rect = new Rectangle(200, 160);
			rect.position.setOrigin(100, 80);
			rect.position.setXYBetween(0, 0, 800, 600, 50, 50);
			rect.lineOpacity = 1;
			rect.lineColor.rgb = 0xff0000;
			rect.lineStrenght = 4;
			Kala.world.add(rect);
			
			var polygon = new Polygon([
				new Vec2(0, 0),
				new Vec2(160, 160),
				new Vec2(160, 0)
			]);
			polygon.position.setOrigin(80, 80);
			polygon.position.setXYBetween(0, 0, 800, 600, 80, 50);
			polygon.fillOpacity = 0;
			polygon.lineOpacity = 1;
			polygon.lineStrenght = 2;
			Kala.world.add(polygon);
			
		});
		
		Kala.start();
		
	}
	
}
```


#####KEYBOARD, MOUSE INPUT & OBJECT TRANSFORMATION

The way Kala handles access to user input states is inspired by HaxeFlixel.

```haxe
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
```

#####GROUP TRANSFORMATION

Objects can be grouped together and they will inherit their groups settings and transformation. One object can be added to multiple groups.

```haxe
package;

import kala.Kala;
import kala.input.Keyboard;
import kala.input.Mouse;
import kala.math.Color.ColorBlendMode;
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
			rect.position.setOrigin(100, 80);
			rect.position.setXY( -200, 0);
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
```