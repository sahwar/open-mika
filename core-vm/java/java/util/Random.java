/**************************************************************************
* Copyright (c) 2001 by Punch Telematix. All rights reserved.             *
*                                                                         *
* Redistribution and use in source and binary forms, with or without      *
* modification, are permitted provided that the following conditions      *
* are met:                                                                *
* 1. Redistributions of source code must retain the above copyright       *
*    notice, this list of conditions and the following disclaimer.        *
* 2. Redistributions in binary form must reproduce the above copyright    *
*    notice, this list of conditions and the following disclaimer in the  *
*    documentation and/or other materials provided with the distribution. *
* 3. Neither the name of Punch Telematix nor the names of                 *
*    other contributors may be used to endorse or promote products        *
*    derived from this software without specific prior written permission.*
*                                                                         *
* THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED          *
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF    *
* MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.    *
* IN NO EVENT SHALL PUNCH TELEMATIX OR OTHER CONTRIBUTORS BE LIABLE       *
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR            *
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF    *
* SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR         *
* BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,   *
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE    *
* OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN  *
* IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                           *
**************************************************************************/


/*
** $Id: Random.java,v 1.2 2006/04/18 11:35:28 cvs Exp $
*/

package java.util;

public class Random implements java.io.Serializable {

  private static final long serialVersionUID = 3905348978240129619L;
  
  private long seed;
  private double nextNextGaussian;
  private boolean haveNextNextGaussian;

  private transient Long saved_seed;

  public Random() {
    if (saved_seed == null) {
      saved_seed = new Long(System.currentTimeMillis());

      this.seed = (saved_seed.longValue() ^ 0x5DEECE66DL) & ((1L<<48) - 1);
    }

    setSeed(saved_seed.longValue());
  }

  public Random(long seed) {
    setSeed(seed);
  }

  public void setSeed(long seed) {
    this.seed = (seed ^ 0x5DEECE66DL) & ((1L<<48) - 1);
    haveNextNextGaussian = false;
  }

  protected int next(int bits) {
    seed = (seed * 0x5DEECE66DL + 0xBL) & ((1L << 48) - 1);
    return (int)(seed >>> (48-bits));
  }

  public int nextInt() {
    return next(32);
  }

  public int nextInt(int n) {
  	if (n<=0) {
   		throw new IllegalArgumentException("n must be positive");
    }
    if ((n & -n) == n)  {// i.e., n is a power of 2
      return (int)((n * (long)next(31)) >> 31);
    }
    int bits, val;
    do {
      bits = next(31);
      val = bits % n;
    } while(bits - val + (n-1) < 0);

    return val;
  }

  public long nextLong() {
    return ((long)next(32)<<32) + next(32);
  }

  public float nextFloat() {
    return next(24) / ((float)(1<<24));
  }

  public double nextDouble() {
    return (((long)next(26)<<27) + next(27)) / (double)(1L<<53);
  }

  public double nextGaussian(){
    if (haveNextNextGaussian) {
      haveNextNextGaussian = false;
      return nextNextGaussian;
    }
    else {
      double v1, v2, s;
      do {
        v1 = 2 * nextDouble() - 1;
        v2 = 2 * nextDouble() - 1;
        s = v1 * v1 + v2 * v2;
      } while (s >= 1);
      double norm = Math.sqrt(-2 * Math.log(s)/s);
      nextNextGaussian = v2 * norm;
      haveNextNextGaussian = true;
      return v1 * norm;
    }
  }

  public void nextBytes(byte [] buf){
   	for (int i=0; i < buf.length ; i++){
   	 	buf[i] = (byte)next(8);
   	}
  }

  public boolean nextBoolean() {
  	return next(1) != 0;
  }
}

