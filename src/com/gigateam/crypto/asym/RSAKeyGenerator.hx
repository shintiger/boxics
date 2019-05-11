package com.gigateam.crypto.asym;
import com.gigateam.crypto.PrimeGenerator;
import thx.BigInt;

/**
 * ...
 * @author Tiger
 */

class RSAKeyGenerator 
{
	private var _n:BigInt;
	private var _p:BigInt;
	private var _q:BigInt;
	private var _e:BigInt;
	private var _d:BigInt;
	private static inline var DEFAULT_PUBLIC_E:Int = 65537;
	public function new(primes:Array<Int>=null, pIndex:Int=-1, qIndex:Int=-1) 
	{
		if (pIndex < 0){
			pIndex = Std.random(primes.length);
		}
		_p = BigInt.fromInt(primes[pIndex]);
		if (qIndex < 0){
			qIndex = Std.random(primes.length);
		}
		_q = BigInt.fromInt(primes[qIndex]);
		while (_q.equalsTo(_p)){
			_q = BigInt.fromInt(primes[Std.random(primes.length)]);
		}
	}
	/*
	private function gcd(a:Int, b:Int):Int{
		while (b != 0){
			var c:Int = b;
			b = a % b;
			a = c;
		}
		return a;
	}
	private function euler(prime:Int):Int{
		if (prime<=2){
			return 1;
		}
		
		var ans:Int = 1;
		var i:Int;
		for (i in 2...prime){
			if (gcd(i, prime)==1){
				ans += 1;
			}
		}	
		return ans;
	}
	*/
	private function egcd(a:BigInt, b:BigInt):Array<BigInt>{
		if (a == 0){
			return [b, 0, 1];
		}
		var r:Array<BigInt> = egcd(b % a, a);
		var g:BigInt = r[0];
		var y:BigInt = r[1];
		var x:BigInt = r[2];
		return [g, x - (b / a) * y, y];
	}
	private function modinv(a:BigInt, n:BigInt):BigInt{
		var r:Array<BigInt> = egcd(a, n);
		var g:BigInt = r[0];
		var x:BigInt = r[1];
		var y:BigInt = r[2];
		if(g != 1){
			//throw new Exception('modular inverse does not exist')
		}else if(x<0){
			return x + n;
		}else{
			return x;
		}
		return (n + a.gcd(n)) / a;
	}
	private function _generate(p:BigInt, q:BigInt):Void{
		_n = p * q;
		var euler_n:BigInt = (p - 1) * (q - 1);
		_e = BigInt.fromInt(DEFAULT_PUBLIC_E);
		var ranMin:Int = 2;
		while (true){
			//if (gcd(_e, euler_n)==1){
			if (_e.gcd(euler_n)==1){
				break;
			}
			//e = random.randint(2, euler_n - 1)
			_e = Std.random(euler_n - 1 - ranMin) + ranMin;
		}
		_d = modinv(_e, euler_n);
	}
	public function generate():RSAKey{
		_generate(_p, _q);
		var key:RSAKey = new RSAKey(_n, _e, _d);
		return key;
	}
	public static function generatePrimes(from:Int, count:Int, margin:Int=0):Array<Int>{
		return _generatePrimes(from, count, margin);
	}
	public static function generatePrimesWith(from:Int, count:Int, margin:Int=0):Array<Int>{
		return _generatePrimes(from, count, margin);
	}
	private static function _generatePrimes(from:Int, count:Int, margin:Int):Array<Int>{
		var D:Map<Int, Array<Int>> = new Map<Int, Array<Int>>();
		var q:Int = 2;
		var primes:Array<Int> = [];
		var offseting:Int = margin;
		while (true){
			if (!D.exists(q)){
				//Prime found-----------------
				if (q > from){
					if (offseting >= margin){
						offseting = 0;
						primes.push(q);
						
						if (primes.length >= count){
							break;
						}
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
			q++;
		}
		return primes;
	}
}