﻿package svelto.efw.plugins.keyboard {	import flash.display.MovieClip;	import flash.display.Stage;	import flash.events.Event;	import flash.events.KeyboardEvent;	import flash.ui.Keyboard;	import svelto.efw.plugins.keyboard.enums.*;		/**	 * Manager for keyboard-based input	 * Example of practical use for this:	 * KeySmith.init(documentClass);	 * if(KeySmith.isKeyDown(Keys.UP))	 * { do stuff for the key held down }	 * @author Stephen Smith	 */	internal class KeySmithManager extends MovieClip	{				/**Start Variables**/				//The current set of keys 		private var keys:Object = KeySets.EMPTY_SET;				//The array to hold the booleans for key down		private var keysDown:Array;		//The array to hold the previous booleans for key down, set on each leave frame		private var prevKeysDown:Array;		//Array to hold the indeces that have been modified since the last update		private var indexChanges:Array;				/** End Variables **/				/**Start Initialization**/				/**		 * Initializes KeySmith		 * @param	document	The document class to add this as a child		 * @param	defaultSet = KeySets.EMPTY_SET	An optional set to pass in		 */		public function init(document:Stage, defaultSet:Object = null):void {			//_instance = new KeySmith(defaultSet);			if (defaultSet == null) defaultSet = KeySets.EMPTY_SET;			changeKeySet(defaultSet);			document.addChild(this);		}				/**		 * Constructor for KeyboardState		 * If you call this not through init, you MUST add this as a child to a movie clip.		 * @param	keyboardState	Default key set. If left blank, makes a normal keyboard manager with an empty set. If given a param, copies the set		 */		public function KeySmithManager() 		{			keysDown = new Array();			prevKeysDown = new Array();			indexChanges = new Array();			addEventListener(Event.ADDED_TO_STAGE, added);		}				/**		 * Adds the Keyboard listeners to the stage		 * @param	e	Event.ADDED_TO_STAGE		 */		private function added(e:Event):void {			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);			stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);			stage.addEventListener(Event.EXIT_FRAME, copyKeyArray);			trace("KeySmith loaded");			removeEventListener(Event.ADDED_TO_STAGE, added);		}				/** End Initialization **/				/**Start Public Functions**/				/**		 * Checks to see if the key is pressed (is down now and was up last frame).		 * @param	keyName	The key to check		 * @return	true if the key is down this frame and was down last frame		 */		public function isKeyPressed(keyName:String):Boolean {			return isKeyDown(keyName) && wasKeyUp(keyName);		}				/**		 * Checks to see if the key is pressed (is down now and was up last frame).		 * @param	keyName	The key to check		 * @return	true if the key is up this frame and was down last frame		 */		public function isKeyReleased(keyName:String):Boolean {			return isKeyUp(keyName) && wasKeyDown(keyName);		}				/**		 * Checks to see if a key is currently down		 * @param	keyName	the key to check		 * @return	true if the key is down		 */		public function isKeyDown(keyName:String):Boolean {			return keysDown[key(keyName)];		}				/**		 * Checks to see if a key is currently down		 * @param	keyName	the key to check		 * @return	true if the key is up		 */		public function isKeyUp(keyName:String):Boolean {			return !keysDown[key(keyName)];		}				/**		 * Checks to see if a key was down last frame		 * @param	keyName	the key to check		 * @return	true if the key was down		 */		public function wasKeyDown(keyName:String):Boolean {			return prevKeysDown[key(keyName)];		}				/**		 * Checks to see if a key was up last frame		 * @param	keyName	the key to check		 * @return	true if the key is up		 */		public function wasKeyUp(keyName:String):Boolean {			return !prevKeysDown[key(keyName)];		}				/**		 * Checks to see if the key combo is pressed (is down now and was up last frame).		 * @param	key1	The first key in the combo		 * @param	key2	The second key in the combo		 * @param	... keysInCombo	The rest of the keys in the combo, if necessary		 * @return	true if every key is down this fram and if every key was not down last frame		 */		public function isKeyComboPressed(key1:String, key2:String, ... keysInCombo):Boolean {			if (keysInCombo.length == 1 && keysInCombo[0] is Array) keysInCombo = keysInCombo.pop();			var wasAnyUp:Boolean = false;						keysInCombo.push(key1, key2); //Adds the two keys to the array, 						for each(var s:String in keysInCombo) {				if (isKeyUp(s)) return false;	//If any of the keys passed in are false, return false (not all down)				else wasAnyUp = wasAnyUp || wasKeyUp(s);	//If any of the keys were up last time, then it was just pressed			}						return wasAnyUp;		}				/**		 * Checks to see if a list of keys are all pressed this frame		 * @param	key1	The first key in the combo		 * @param	key2	The second key in the combo		 * @param	... keysInCombo	The rest of the keys in the combo, if necessary		 * @return	true if the every key is down this frame		 */		public function isKeyComboDown(key1:String, key2:String, ... keysInCombo):Boolean {			if (keysInCombo.length == 1 && keysInCombo[0] is Array) keysInCombo = keysInCombo.pop();			var b:Boolean = true;						keysInCombo.push(key1, key2); //Adds the two keys to the array, 						for each(var s:String in keysInCombo)				b = b && isKeyDown(s);							return b;		}				/**		 * Checks to see if a list of keys are all released		 * @param	key1	The first key in the combo		 * @param	key2	The second key in the combo		 * @param	... keysInCombo	The rest of the keys in the combo, if necessary		 * @return	true if the every key is up this frame this frame		 */		public function isKeyComboUp(key1:String, key2:String, ... keysInCombo):Boolean {			if (keysInCombo.length == 1 && keysInCombo[0] is Array) keysInCombo = keysInCombo.pop();			var b:Boolean = true;						keysInCombo.push(key1, key2); //Adds the two keys to the array, 						for each(var s:String in keysInCombo)				b = b && isKeyUp(s);							return b;		}				/**		 * Checks to see if a list of keys are all pressed last frame		 * @param	key1	The first key in the combo		 * @param	key2	The second key in the combo		 * @param	... keysInCombo	The rest of the keys in the combo, if necessary		 * @return	true if the every key was down last frame		 */		public function wasKeyComboDown(key1:String, key2:String, ... keysInCombo):Boolean {			if (keysInCombo.length == 1 && keysInCombo[0] is Array) keysInCombo = keysInCombo.pop();			var b:Boolean = true;						keysInCombo.push(key1, key2); //Adds the two keys to the array, 						for each(var s:String in keysInCombo)				b = b && wasKeyDown(s);							return b;		}				/**		 * Checks to see if a list of keys are all released last frame		 * @param	key1	The first key in the combo		 * @param	key2	The second key in the combo		 * @param	... keysInCombo	The rest of the keys in the combo, if necessary		 * @return	true if the every key was up last frame		 */		public function wasKeyComboUp(key1:String, key2:String, ... keysInCombo):Boolean {			if (keysInCombo.length == 1 && keysInCombo[0] is Array) keysInCombo = keysInCombo.pop();			var b:Boolean = true;						keysInCombo.push(key1, key2); //Adds the two keys to the array, 						for each(var s:String in keysInCombo)				b = b && wasKeyUp(s);							return b;		}				/**		 * Checks to see if any key is pressed (is up this frame and was down last frame)		 * @param	key1	The first key in the combo		 * @param	key2	The second key in the combo		 * @param	... otherKeys	The rest of the keys to check, if necessary		 * @return	true if any keys are pressed this frame		 */		public function isAnyKeyPressed(key1:String, key2:String, ... otherKeys):Boolean {			if (otherKeys.length == 1 && otherKeys[0] is Array) otherKeys = otherKeys.pop();			otherKeys.push(key1, key2);			for each(var s:String in otherKeys)				if (isKeyDown(s) && wasKeyUp(s)) return true;							return false;		}				/**		 * Checks to see if any key is down		 * @param	key1	The first key in the combo		 * @param	key2	The second key in the combo		 * @param	... otherKeys	The rest of the keys to check, if necessary		 * @return	true if any keys are down this frame		 */		public function isAnyKeyDown(key1:String, key2:String, ... otherKeys):Boolean {			if (otherKeys.length == 1 && otherKeys[0] is Array) otherKeys = otherKeys.pop();			otherKeys.push(key1, key2);			for each(var s:String in otherKeys)				if (isKeyDown(s)) return true;							return false;		}				/**		 * Checks to see if any key is down		 * @param	key1	The first key in the combo		 * @param	key2	The second key in the combo		 * @param	... otherKeys	The rest of the keys to check, if necessary		 * @return	true if any keys are up this frame		 */		public function isAnyKeyUp(key1:String, key2:String, ... otherKeys):Boolean {			if (otherKeys.length == 1 && otherKeys[0] is Array) otherKeys = otherKeys.pop();			otherKeys.push(key1, key2);			for each(var s:String in otherKeys)				if (isKeyUp(s)) return true;							return false;		}				/**		 * Checks to see if any key is down		 * @param	key1	The first key in the combo		 * @param	key2	The second key in the combo		 * @param	... otherKeys	The rest of the keys to check, if necessary		 * @return	true if any keys were down last frame		 */		public function wasAnyKeyDown(key1:String, key2:String, ... otherKeys):Boolean {			if (otherKeys.length == 1 && otherKeys[0] is Array) otherKeys = otherKeys.pop();			otherKeys.push(key1, key2);			for each(var s:String in otherKeys)				if (wasKeyDown(s)) return true;							return false;		}				/**		 * Checks to see if any key is down		 * @param	key1	The first key in the combo		 * @param	key2	The second key in the combo		 * @param	... otherKeys	The rest of the keys to check, if necessary		 * @return	true if any keys were up last frame		 */		public function wasAnyKeyUp(key1:String, key2:String, ... otherKeys):Boolean {			if (otherKeys.length == 1 && otherKeys[0] is Array) otherKeys = otherKeys.pop();			otherKeys.push(key1, key2);			for each(var s:String in otherKeys)				if (wasKeyUp(s)) return true;							return false;		}				/**		 * Gets the current state of a given keycode: true if pressed and false if released.		 * Normally, the key should be aliased instead. Use only if needed.		 * @param	keyCode	The keycode to check.		 * @return	true if down and false if up		 */		public function keyCodeState(keyCode:uint):Boolean {			return keysDown[keyCode];		}				/**		 * Gets the previous state of a given keycode: true if pressed and false if released.		 * Normally, the key should be aliased instead. Use only if needed.		 * @param	keyCode	The keycode to check.		 * @return	true if down and false if up		 */		public function prevKeyCodeState(keyCode:uint):Boolean {			return prevKeysDown[keyCode];		}				/**		 * Returns the keycode of a key given its alias.		 * @param	name	The alias of the key (e.g. "UP" or Keys.UP)		 * @return	The KeyCode with that alias		 */		public function key(name:String):uint {			return keys[name];		}				/**		 * Will add a new key to the collection.		 * If the key exists or the key code is in use, it will not be added		 * @param	name	The name of the key to add		 * @param	keyCode	The keyCode to assign it to		 * @return	true if the key was added or false if not		 */		public function addKey(name:String, keyCode:uint):Boolean {			for (var check:String in keys) {				if (check == name) return false;			}			var s:String = findKey(keyCode);			if (s != null) delete keys[s];			changeKey(name, keyCode);						return true;		}				/**		 * Attempts to delete a key alias		 * @param	name	The name of the key to delete		 */		public function deleteKey(name:String):void {			delete keys[name];		}				/**		 * Changes a key to a different keyCode. This will switch two if the given keyCode already has an alias.		 * This method will do nothing if the key has not been added.		 * @param	name	The name of the key to change		 * @param	keyCode	The keycode to change it to		 */		public function changeKey(name:String, keyCode:uint):void {			var s:String = findKey(keyCode);			if (s == null) {				keys[name] = keyCode;			} else {				keys[s] = keys[name];				keys[name] = keyCode;			}		}				/**		 * Loads in a default keyset		 * @param	setName	The name of the set to change to (KEY_SET or WASD_SET)		 */		public function changeKeySet(newSet:Object):void {			keys = { };			for (var key:String in newSet) {				keys[key] = newSet[key];			}		}						/**		 * Creats a sstring representation of the current key set		 * @return	A string of the current key setup		 */		public function getKeySetString():String {			var s:String = "";			s += "{ ";			for (var key:String in keys)				s += key + ":" + getKeySymbol(keys[key]) + " ";			s += "}";						return s;		}				/**		 * Gets a copy of the array of booleans for current key downs		 * Use this for logging purposes, not to check keys.		 * @return	a copy of keyDown		 */		public function getKeysDown():Array {			return cloneArray(keysDown);		}				/**		 * Gets a copy of the array of booleans for previous key downs		 * Use this for logging purposes, not to check keys.		 * @return	a copy of prevKeyDown		 */		public function getPrevKeysDown():Array {			return cloneArray(prevKeysDown);		}				/**		 * Returns information about the object (useful for debugging)		 * @return	a string representation of the keys down		 */		public override function toString():String {			var s:String = "KeySmith:";						s += "\n         Keys Down:";			s += debugPrint(keysDown);						s += "\nPrevious Keys Down:";			s += debugPrint(prevKeysDown);						s += "\n   Current Key Set:";			s += getKeySetString();						return s;		}				/** End Public Functions **/				/**Start Helper Functions**/				/**		 * Checks to see if the value is in the key collection.		 * @param	value	The key code to check		 * @return	The key if it the value is assigned and null if it is not.		 */		private function findKey(value:uint):String {			for (var key:String in keys) {				if (keys[key] == value) return key;			}			return null;		}				/**		 * Gets a string for debugging an array		 * @param	arr	The array to get the string from		 * @return	The string representing what characters are down		 */		private function debugPrint(arr:Array):String {			var s:String = "";			for(var i:uint = 0; i<arr.length; i++) {				if(arr[i]) {					s += " " + getKeySymbol(i);				}			}			return s;		}				/**		 * Gets the formated keycode of a given key		 * There is no good way to do this.		 * @param	keyCode	The code of the key (i.e. array's index)		 * @return	The formatted representation of most keys		 */		private function getKeySymbol(keyCode:uint):String {			switch(keyCode) {				case Keyboard.UP:					return "[Up Arrow]";				case Keyboard.DOWN:					return "[Down Arrow]";				case Keyboard.LEFT:					return "[Left Arrow]";				case Keyboard.RIGHT:					return "[Right Arrow]";				case Keyboard.ALTERNATE:					return "[Alt/Option]";				case Keyboard.BACKQUOTE:					return "`";				case Keyboard.BACKSLASH:					return "\\";				case Keyboard.BACKSPACE:					return "[Backspace]";				case Keyboard.CAPS_LOCK:					return "[Caps Lock]";				case Keyboard.COMMA:					return ",";				case Keyboard.COMMAND:					return "[Command]";				case Keyboard.CONTROL:					return "[Control]";				case Keyboard.DELETE:					return "[Delete]";				case Keyboard.END:					return "[End]";				case Keyboard.ENTER:					return "[Enter]";				case Keyboard.EQUAL:					return "=";				case Keyboard.ESCAPE:					return "[Esc]";				case Keyboard.F1:					return "[F1]";				case Keyboard.F2:					return "[F2]";				case Keyboard.F3:					return "[F3]";				case Keyboard.F4:					return "[F4]";				case Keyboard.F5:					return "[F5]";				case Keyboard.F6:					return "[F6]";				case Keyboard.F7:					return "[F7]";				case Keyboard.F8:					return "[F8]";				case Keyboard.F9:					return "[F9]";				case Keyboard.F10:					return "[F10]";				case Keyboard.F11:					return "[F11]";				case Keyboard.F12:					return "[F12]";				case Keyboard.HOME:					return "[Home]";				case Keyboard.INSERT:					return "[Insert]";				case Keyboard.LEFTBRACKET:					return "[";				case Keyboard.MINUS:					return "-";				case Keyboard.NUMPAD:					return "[Numpad]";				case Keyboard.NUMPAD_0:					return "[Numpad 0]";				case Keyboard.NUMPAD_1:					return "[Numpad 1]";				case Keyboard.NUMPAD_2:					return "[Numpad 2]";				case Keyboard.NUMPAD_3:					return "[Numpad 3]";				case Keyboard.NUMPAD_4:					return "[Numpad 4]";				case Keyboard.NUMPAD_5:					return "[Numpad 5]";				case Keyboard.NUMPAD_6:					return "[Numpad 6]";				case Keyboard.NUMPAD_7:					return "[Numpad 7]";				case Keyboard.NUMPAD_8:					return "[Numpad 8]";				case Keyboard.NUMPAD_9:					return "[Numpad 9]";				case Keyboard.NUMPAD_ADD:					return "[Numpad +]";				case Keyboard.NUMPAD_DECIMAL:					return "[Numpad .]";				case Keyboard.NUMPAD_DIVIDE:					return "[Numpad /]";				case Keyboard.NUMPAD_ENTER:					return "[Numpad Enter]";				case Keyboard.NUMPAD_MULTIPLY:					return "[Numpad *]";				case Keyboard.NUMPAD_SUBTRACT:					return "[Numpad -]";				case Keyboard.PAGE_DOWN:					return "[Page Down]";				case Keyboard.PAGE_UP:					return "[Page Up]";				case Keyboard.PERIOD:					return ".";				case Keyboard.QUOTE:					return "'";				case Keyboard.RIGHTBRACKET:					return "]";				case Keyboard.SEMICOLON:					return ";";				case Keyboard.SHIFT:					return "[Shift]";				case Keyboard.SLASH:					return "/";				case Keyboard.TAB:					return "[Tab]";				case 91:	//Windows Key, no const for it					return "[Windows]";				case 184:	//Num Lock, no const for it					return "[Num Lock]";				default:					return "'" + String.fromCharCode(keyCode) + "'";			}		}				/**		 * Makes a copy of an array to avoid preturning references		 * @param	arr	The array to copy		 * @return	A copy of the array		 */		private function cloneArray(arr:Array):Array {			var retArray:Array = new Array();			for (var i:int = 0; i < arr.length; i++) {				retArray[i] = arr[i];			}			return retArray;		}				/**		 * Takes an index of the keyArray and adds it to the list of changes since the last update		 * Helper function for keyPressed and keyDown		 * @param	changeIndex		 */		private function recordChange(changeIndex:uint):void {			if (indexChanges.indexOf(changeIndex) == -1)				indexChanges.push(changeIndex);		}		/** End Helper Functions **/				/**Start Listeners**/				/**		 * Event listener for pressing a key		 * @param	ke	KeyboardEvent.KEY_DOWN		 */		private function keyPressed(ke:KeyboardEvent):void {			keysDown[ke.keyCode] = true;			recordChange(ke.keyCode);		}				/**		 * Event listener for releasing a key		 * @param	ke	KeyboardEvent.KEY_UP		 */		private function keyReleased(ke:KeyboardEvent):void {			keysDown[ke.keyCode] = false;			recordChange(ke.keyCode);		}				/**		 * Event listener to copy the current key array to the previous		 * @param	e	Event.EXIT_FRAME		 */		private function copyKeyArray(e:Event):void {			while(indexChanges.length > 0) {				var index:uint = indexChanges.pop();				prevKeysDown[index] = keysDown[index];			}		}		/** End Listeners **/	}}