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
6. [Group view](https://github.com/hazagames/Kala#group-view)
7. [Text](https://github.com/hazagames/Kala#text)

#####HELLO WORLD

```haxe
package;

import kala.Kala;
import kala.objects.text.BasicText;
import kha.Assets;

class Main {
	
	public static function main() {
		
		// Kala.world is the root group that contains all other objects. Group is also a type of object.
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
		
		// Does just what you would expect.
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
			
			var rect = new Rectangle(200, 160, true, true);
			rect.position.setOrigin(100, 80).setXYBetween(0, 0, 800, 600, 50, 50);
			rect.lineColor.rgb = 0xff0000;
			rect.lineStrenght = 4;
			Kala.world.add(rect);
			
			var polygon = new Polygon([
				new Vec2(0, 0),
				new Vec2(160, 160),
				new Vec2(160, 0)
			], false);
			polygon.position.setOrigin(80, 80).setXYBetween(0, 0, 800, 600, 80, 50);
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
import kala.objects.shapes.Rectangle;

class Main {
	
	public static function main() {
		
		Kala.world.onFirstFrame.add(function(_) {
			
			var rect = new Rectangle(200, 100);
			rect.position.setOrigin(100, 50);
		
			// Each of these transformation has their own origin point.
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
				
				// Currently Mouse.wheel works incorrectly on HTML5 target.
				//rect.skew.y += Mouse.wheel;
		
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
			rect.position.setOrigin(100, 80).setXY( -200, 0);
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

#####GROUP VIEW

```haxe
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
```

#####TEXT

```haxe
package;

import kala.Kala;
import kala.input.Keyboard;
import kala.objects.text.BasicText;
import kala.objects.text.Text;
import kala.objects.text.TextAlign;
import kha.Assets;

class Main {
	
	public static function main() {
		
		Kala.world.onFirstFrame.add(function(_) {
			
			Kala.defaultFont = Assets.fonts.ClearSans_Regular;
			
			// BasicText is used for simple text rendering without fancy formatting.
			// Use it when possible for better performance.
			var basicText = new BasicText();  
			Kala.world.add(basicText);
			
			// And we have Text for fancy stuffs.
			var fancyText = new Text(null, null, 30, 700, TextAlign.JUSTIFY);
			fancyText.text = "TO CHANGE ALIGNMENT MODE PRESS:\n[1] LEFT\n[2] CENTER\n[3] RIGHT\n[4] JUSTIFY\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
			fancyText.bgColor.rgb = 0x00ffff;
			fancyText.bgOpacity = 0.2;
			fancyText.borderOpacity = 1;
			fancyText.borderSize = 2;
			fancyText.padding.set(15, 15);
			fancyText.position.set(50, 60);
			Kala.world.add(fancyText);
			
			Kala.world.onPostUpdate.add(function(_, _) {
				basicText.text = "" + Kala.fps;
				
				if (Keyboard.justPressed.ONE) fancyText.align = TextAlign.LEFT;
				if (Keyboard.justPressed.TWO) fancyText.align = TextAlign.CENTER;
				if (Keyboard.justPressed.THREE) fancyText.align = TextAlign.RIGHT;
				if (Keyboard.justPressed.FOUR) fancyText.align = TextAlign.JUSTIFY;
			});
			
		});

		Kala.start(); 
		
	}
	
}
```

#####COLLISION DETECTION

Collider is a component using SAT for collision detection. It can be applied to all objects. There will be another type of this component specific for shapes.

Collision shapes will always get transformed correctly as theirs objects get transformed.

You can also use kala.math.Collision directly without the component for better performance. We can forget the awkward bounding box.

```haxe
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
```