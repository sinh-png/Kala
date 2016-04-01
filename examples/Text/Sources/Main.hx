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

		// Does just what you expect.
		Kala.start("Hello!", 800, 600); 
		
	}
	
}
