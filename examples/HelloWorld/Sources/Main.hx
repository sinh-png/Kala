package;

import kala.Kala;
import kala.objects.text.BasicText;
import kha.Assets;

class Main {
	
	public static function main() {
		
		// Kala.world is the root group that contains all other objects. Group is also a type of object.
		// onFirstFrame is a handle for callbacks that will be executed right before the first update / draw of an object. 
		Kala.world.onFirstFrame.notify(function(_) {
			
			// We set a default font that will be used for all text rendering.
			Kala.defaultFont = Assets.fonts.ClearSans_Regular;
			
			var text = new BasicText("HELLO WORLD", 40);
			text.position.set(400, 300, text.width / 2, text.height / 2); // Center the text on screen.
			text.color = 0xff00ffff; // Make it aqua blue because I like the color.  
			Kala.world.add(text); // Add it into the root group.
			
		});
		
		// Does just what you expect.
		Kala.start("Hello!", 800, 600); 
		
	}
	
}
