/**************************************************************************
* Copyright (c) 2001, 2002, 2003 by Punch Telematix. All rights reserved. *
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

package java.awt;

import java.awt.event.KeyEvent;

public class MenuShortcut implements java.io.Serializable {

  /*
  ** Fields needed for Serialization.
  */

  int key;
  boolean usesShift;

  // From Apache Harmony
  static boolean isShortcut(KeyEvent ke) {
      return ke.isControlDown();
  }

  static MenuShortcut lookup(KeyEvent ke) {
    if (ke.isControlDown()) {
      return new MenuShortcut(ke.getKeyCode(), ke.isShiftDown());
    }
    return null;
  }

  public MenuShortcut(int keyCode) {
    this(keyCode, false);
  }
  
  public MenuShortcut(int keyCode, boolean useShift) {
    key = keyCode;
    usesShift = useShift;
  }

  public boolean equals(MenuShortcut shortcut) {
    return (shortcut.key == key) && (shortcut.usesShift == usesShift);
  }

  public int getKey() {
    return key;
  }

  public boolean useShiftModifier() {
    return usesShift;
  }

  protected String paramString() {
    return null;
  }

  public String toString() {
    return null;
  }
  
}

