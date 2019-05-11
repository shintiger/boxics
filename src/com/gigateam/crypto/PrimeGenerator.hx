package com.gigateam.crypto;

/**
 * ...
 * @author Tiger
 */
class PrimeGenerator 
{
	private var _from:Int;
	private var _count:Int;
	private var _margin:Int;
	
	private var D:Map<Int, Array<Int>>;
	private var q:Int = 1;
	private var offseting:Int;
	private var returnedCount:Int = 0;
	private var percentageCursor:Float = 0;
	public function new(from:Int, count:Int, margin:Int)
	{
		D = new Map<Int, Array<Int>>();
		_from = from;
		_count = count;
		_margin = margin;
		
		offseting = margin;
	}
	public function progressRatio(expectedPercentage:Float):Float{
		var percent:Float = returnedCount / _count;
		if ((percent - percentageCursor) > expectedPercentage){
			percentageCursor = percent;
			return percent;
		}
		return 0;
	}
	public function fetchAll():Array<Int>{
		var result:Int = 0;
		var primes:Array<Int> = [];
		while (true){
			result = fetch();
			if (result < 0){
				break;
			}
			primes.push(result);
		}
		return primes;
	}
	public function fetch():Int{
		var result:Int = 0;
		while (true){
			q++;
			if (!D.exists(q)){
				//Prime found-----------------
				if (q > _from){
					if (offseting >= _margin){
						offseting = 0;
						if (returnedCount >= _count){
							return -1;
						}
						result = q;
					}else{
						offseting += 1;
					}
				}
				//Prime found end-----------------
				D.set(q * q, [q]);
			}else{
				for (p in D[q]){
					var sum:Int = p + q;
					if (!D.exists(sum)){
						D.set(sum, [p]);
					}else{
						D.get(sum).push(p);
					}
				}
				D.remove(q);
			}
			if (result != 0){
				returnedCount++;
				return result;
			}
		}
	}
}