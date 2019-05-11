package com.gigateam.crypto.asym;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesData;
import thx.BigInt;

/**
 * ...
 * @author Tiger
 */
class RSA 
{
	public function new() 
	{
		
	}
	public static function encrypt(content:Int, key:RSAKey):String{
		if (!key.isPair()){
			//return 0;
		}
		//var encrypted:BigInt = modpow(BigInt.fromInt(content), key.e, key.n);
		if (key.n < content){
			return "";
		}
		var encrypted:BigInt = BigInt.fromInt(content).modPow(key.e, key.n);
		return encrypted.toString();
	}
	public static function decrypt(content:String, key:RSAKey):String{
		if (key.isPair()){
			//return 0;
		}
		//var decrypted:Int = Std.int(Math.pow(content, key.d) % key.n);
		
		//var decrypted:BigInt = modpow(BigInt.fromString(content.toString()), key.d, key.n);
		var decrypted:BigInt = BigInt.fromString(content).modPow(key.d, key.n);
		return decrypted.toString();
	}
	/*private static function modpow(b:BigInt, e:Int, m:Int):BigInt{
		var result:BigInt = BigInt.fromInt(1);
		var mm:BigInt = BigInt.fromInt(m);
		while (e > 0) {
			if ((e & 1) == 1) {
				//multiply in this bit's contribution while using modulus to keep
				//result small
				result = result.multiply(b).modulo(mm);
			}
			//c = (c * c) % m;
			b = b * b % mm;
			e >>>= 1;
		}
		return result;
	}*/
}