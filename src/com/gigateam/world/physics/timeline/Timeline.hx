package com.gigateam.world.physics.timeline;
import com.gigateam.util.Debugger;
import haxe.ds.Vector;

/**
 * ...
 * @author Tiger
 */
class Timeline 
{
	public static inline var MAX_FRAMES:Int = 50;
	public var offset:Int;
	private var _max:Int;
	private var _length:Int;
	private var _frames:Vector<Keyframe>;
	private var _cursor:Int;
	public function new(_offset:Int, alive:Int=100) 
	{
		_length = 0;
		offset = _offset;
		_frames = new Vector<Keyframe>(MAX_FRAMES);
		_max = alive;
		//insertKeyframe(genesis);
	}
	public function setCursor(time:Int):Void{
		_cursor = time;
	}
	public function getCursor():Int{
		return _cursor;
	}
	public function insertKeyframe(keyframe:Keyframe, clearFramesAfter:Bool=false):Bool{
		var index:Int = _length;
		var needSort:Bool = false;
		if (_length > 0 && keyframe.time < _frames[_length - 1 ].time){
			if(!clearFramesAfter){
				//Debugger.getInstance().log("toInsertKeyframeTime:" + keyframe.time+", lastTime:" + _frames[_length - 1 ].time);
				//throw "Time less than last frame" + keyframe.time+", lastTime:" + _frames[_length - 1 ].time;
				//logAllFrames(true);
				//return false;
				clearFramesAfter = true;
			}
			needSort = true;
		}

		_length++;
		if (_length >= MAX_FRAMES){
			_length--;
			index = purgeExpiredFrames(keyframe.time);
			if (index <0 || index > _length){
				index = removeBeforeIndex(0);
			}
			_length++;
		}
		_frames[index] = keyframe;
		if(needSort){
			sort();
		}
		return true;
	}
	private function purgeExpiredFrames(time:Int):Int{
		//From the end to head, search for latest expired frame's index
		//Latest expired frame found, before i will be replace by after i.
		var expired:Int = latestExpiredIndex(time);
		if (expired < 0){
			return -1;
		}else if (expired >= _length){
			return -2;
		}
		return removeBeforeIndex(expired);
	}
	private function removeBeforeIndex(index:Int):Int{
		var j:Int = 0;
		_length = _length - index - 1;
		while (true){
			if (j == _length)
			break;
			
			_frames[j] = _frames[j + index + 1];
			j++;
		}
		return _length;
	}
	private function latestExpiredIndex(time:Int):Int{
		var i:Int = _length;
		while (true){
			i--;
			if (i < 0){
				//No expired data
				return _length;
			}
			if ((time-_frames[i].time) >= _max){
				return i;
			}
		}
		return -1;
	}
	/*public function insertKeyframe(keyframe:Keyframe):Bool{
		var i:Int = 0;
		var j:Int = 0;
		while (true){
			if (i > _length || i > MAX_FRAMES){
				return false;
			}
			if (i == _length){
				Debugger.getInstance().setString("aa:"+i);
				_insertKeyframe(i, keyframe);
				break;
			}
			if (_frames[i].time > keyframe.time){
				Debugger.getInstance().setString("bb");
				j = _length-1;
				var k:Int = 0;
				while (true){
					if (j == 0 || j==i)
					break;
					
					k = j;
					k--;
					_frames[j] = _frames[k];
					j = k;
				}
				Debugger.getInstance().setString("cc");
				_insertKeyframe(i, keyframe);
				break;
			}
			i++;
		}
		return true;
	}
	private function _insertKeyframe(index:Int, keyframe:Keyframe):Void{
		Debugger.getInstance().setString("cc:"+index);
		_frames[index] = keyframe;
		_length++;
		Debugger.getInstance().setString("dd");
		//if (_length >= _frames.length){
		if(true){
			var i:Int = _length;
			i--;
			var lastTime:Int = _frames[i].time;
			Debugger.getInstance().setString("ee");
			while (true){
				i--;
				if (i < 0)
				break;
				Debugger.getInstance().setString("ff");
				if ((lastTime - _frames[i].time) > _max){
					Debugger.getInstance().setString("jj");
					i++;
					_length = _length - i ;
					var j:Int = 0;
					while (true){
						if (j == _length)
						break;
						
						_frames[j] = _frames[j + i];
						j++;
					}
					break;
				}
			}
		}
	}*/
	public function dispose():Void{
		
	}
	public function sort():Void{
		if (_frames.length < 2)
		return;
		_frames.sort(function(a:Keyframe, b:Keyframe):Int {
			if (a == null || b == null){
				return 0;
			}
		  if (a.time < b.time) return -1;
		  else if (a.time > b.time) return 1;
		  return 0;
		});
	}
	public function totalFrames():Int{
		return _length;
	}
	public function nextFrame(time:Int = 0):Keyframe{
		var i:Int = 0;
		var m:Int = totalFrames();
		var frame:Keyframe;
		while (true){
			if (i >= m)
			break;
			
			if (_frames[i].time > time){
				return _frames[i];
			}
			i++;
		}
		
		return null;
	}
	public function lastFrame(time:Int=0):Keyframe{
		var i:Int=totalFrames();
		var frame:Keyframe;
		if (time == 0 && i>0){
			return _frames.get(i - 1);
		}
		while (true){
			i--;
			if (i < 0)
			break;
			
			if (_frames[i].time <= time){
				return _frames[i];
			}
		}
		//logAllFrames(true);
		
		return null;
	}
	private function logAllFrames(throwError:Bool=false):Void{
		var i:Int = totalFrames();
		var str:String = "";
		while (true){
			i--;
			if (i < 0)
			break;
			
			str += i + ":" + _frames[i].time+", ";
		}
		Debugger.getInstance().log("totalFrames:" + totalFrames());
		Debugger.getInstance().log(str);
		if (throwError){
			Debugger.getInstance().throwError();
		}
	}
}