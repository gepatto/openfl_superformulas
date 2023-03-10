/**
 * Adapted for openfl 
 * from https://www.bit-101.com/blog/2023/02/coding-curves-14-miscellaneous-curves/
 * 
 * Superformulas
 */

package;

import motion.Actuate;
import openfl.display.FPS;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.display.Sprite;
import openfl.display.Graphics;

class Main extends Sprite {

	var info:TextField;
	var tf:TextFormat;
	var shapeSprite:Sprite;
	var shapeIndex:Int = 0;
	var shapeRadius:Float = 100;
	var shapeSymmetry:Float = 1;
	var shapeN1:Float = 1;
	var shapeN2:Float = 1;
	var shapeN3:Float = 1;
	var animateSymmetry:Bool = false;

	var shapes:Array<Array<Float>> = [
		[ 32, .9 ,.2, .3],[ 16, .5 ,.75, 2],
		[8, 1, 2, 1], [3, 4.5, 10, 10], [4, 12, 15, 15], [7, 10, 6, 6], [5, 4, 4, 4], [5, 2, 7, 7], [5, 2, 13, 13], [4, 1, 1, 1], [4, 1, 7, 8], [6, 1, 7, 8],
		[2, 2, 2, 2], [1, .5, .5, .5], [2, .5, .5, .5], [3, .5, .5, .5], [5, 1, 1, 1], [2, 1, 1, 1], [7, 3, 4, 17], [2, 1, 4, 8], [6, 1, 4, 8], [7, 2, 8, 4],
		[4, .5, .5, 4], [8, .5, .5, 8], [16, .5, .5, 16], [3, 30, 15, 15], [4, 30, 15, 15]];

	public function new() {
		super();
		tf = new TextFormat("null",12,0xfffff);

		info = new TextField();
		info.defaultTextFormat = tf;

		info.x = 8;
		info.y = 32;
		info.width = stage.stageWidth;
		info.height = 128;
		info.multiline = true;

		
		info.textColor = 0xffffff;
		info.text = "Adapted for openfl from https://www.bit-101.com/blog/2023/02/coding-curves-14-miscellaneous-curves/ \n\nUse Keys with or without shiftKey: Space=Next/Previous Shape, Q=Symmetry , W=n1, E=n2, R=n3, UP/Down=radius";

		shapeSprite = new Sprite();
		shapeSprite.x = stage.stageWidth >> 1;
		shapeSprite.y = stage.stageHeight >> 1;

		addChild(shapeSprite);
		addChild(info);
		addChild(new FPS(8,8,0xffffff));
		loadShape();
		drawShape();


		stage.addEventListener(KeyboardEvent.KEY_DOWN, handle_stageKeyUp);
	}

	function handle_stageKeyUp(e:KeyboardEvent) {
		switch (e.keyCode) {
			case Keyboard.SPACE:
				if(e.shiftKey){
					previousShape();
				} else{
					nextShape();
				}
			case Keyboard.UP:
				shapeRadius += .5;
				drawShape();
			case Keyboard.DOWN:
				shapeRadius -= .5;
				drawShape();
			case Keyboard.Q:
				shapeSymmetry += e.shiftKey?-1:1;
				drawShape();
			case Keyboard.W:
				shapeN1 = Math.max(0.2,shapeN1 + (e.shiftKey?-.1:.1));
				drawShape();
			case Keyboard.E:
				shapeN2 = Math.max(0,shapeN2 + (e.shiftKey?-.1:.1));
				drawShape();
			case Keyboard.R:
				shapeN3 = Math.max(0,shapeN3 + (e.shiftKey?-.1:.1));
				drawShape();
			case Keyboard.S:
				animateSymmetry = !animateSymmetry;
			case Keyboard.A:
				if(e.shiftKey){
					stopAnimateShape();
				}else{
					stopAnimateShape();
					animateShape();
				}
	
		}
	}

	function stopAnimateShape(){
		Actuate.reset();
	}

	function animateShape(){
		var symStart = Std.int(1 + Math.random() * 20) *2;
		var symEnd   = Std.int(1 + Math.random() * 20) *2;
		var n1Start  = 0.2 + Math.random() * 5;
		var n1End = 0.2 + Math.random() * 5;
		var n2Start  = 0.2 + Math.random() * 5;
		var n2End = 0.2 + Math.random() * 5;
		var n3Start  = 0.2 + Math.random() * 5;
		var n3End = 0.2 + Math.random() * 5;
		Actuate.update (tweenShape, 1, [symStart,n1Start,n2Start,n3Start], [symEnd,n1End, n2End,n3End] ).repeat().reflect();
	}

	function tweenShape(sym,n1,n2,n3){
		if(animateSymmetry){
			shapeSymmetry = sym;
		}
		shapeN1 = n1;
		shapeN2 = n2;
		shapeN3 = n3;
		drawShape();
	}

	function nextShape() {
		shapeIndex = shapeIndex < shapes.length - 1 ? ++shapeIndex : 0;
		loadShape();
		drawShape();
	}
	
	function previousShape() {
		shapeIndex = shapeIndex > 0 ? --shapeIndex : shapes.length-1;
		loadShape();
		drawShape();
	}

	function loadShape(){
		var s = shapes[shapeIndex];
		shapeSymmetry = s[0];
		shapeN1 = s[1];
		shapeN2 = s[2];
		shapeN3 = s[3];
	}

	function drawShape() {
		superformula(shapeSprite.graphics, 0, 0, shapeRadius, shapeSymmetry, shapeN1, shapeN2, shapeN3);
		info.text = 'Use Keys with or without shiftKey: A=Animate Random, Space=Next/Previous Shape, Q=Symmetry , W=n1, E=n2, R=n3, UP/Down=radius \n\n shapeRadius $shapeRadius, shapeSymmetry $shapeSymmetry, shapeN1 $shapeN1, shapeN2 $shapeN2, shapeN3 $shapeN3';
	}

	function superformula(g:Graphics, xc:Float, yc:Float, radius:Float, symmetry:Float, n1:Float, n2:Float, n3:Float) {
		var t:Float = 0;
		var oX:Float = 0;
		var oY:Float = 0;

		g.clear();
		g.lineStyle(1, 0xff0000);
		g.beginFill(0xff0000, 1);

		while (t <= 2 * Math.PI) {
			var angle = symmetry * t / 4;
			var term1 = Math.pow(Math.abs(Math.cos(angle)), n2);
			var term2 = Math.pow(Math.abs(Math.sin(angle)), n3);
			var r = Math.pow(term1 + term2, -1 / n1) * radius;
			var x = xc + Math.cos(t) * r;
			var y = yc + Math.sin(t) * r;
			if (t == 0) {
				oX = x;
				oY = y;
				g.moveTo(x, y);
			} else {
				g.lineTo(x, y);
			}

			t += 0.01;
		}
		g.endFill();
	}
}
