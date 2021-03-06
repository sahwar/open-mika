/**************************************************************************
* Copyright  (c) 2001 by Acunia N.V. All rights reserved.                 *
*                                                                         *
* This software is copyrighted by and is the sole property of Acunia N.V. *
* and its licensors, if any. All rights, title, ownership, or other       *
* interests in the software remain the property of Acunia N.V. and its    *
* licensors, if any.                                                      *
*                                                                         *
* This software may only be used in accordance with the corresponding     *
* license agreement. Any unauthorized use, duplication, transmission,     *
*  distribution or disclosure of this software is expressly forbidden.    *
*                                                                         *
* This Copyright notice may not be removed or modified without prior      *
* written consent of Acunia N.V.                                          *
*                                                                         *
* Acunia N.V. reserves the right to modify this software without notice.  *
*                                                                         *
*   Acunia N.V.                                                           *
*   Vanden Tymplestraat 35      info@acunia.com                           *
*   3000 Leuven                 http://www.acunia.com                     *
*   Belgium - EUROE                                                      *
**************************************************************************/

/*
** $Id: SQLException.java,v 1.1.1.1 2004/07/12 14:07:46 cvs Exp $
*/

package java.sql;

public class SQLException extends Exception {

  private static final long serialVersionUID = 2135244094396331484L;

  private String SQLState;
  private int vendorCode;
  private SQLException next = null;

  public SQLException() {
    this(null, null, 0);
  }
  
  public SQLException(String reason) {
    this(reason, null, 0);
  }
  
  public SQLException(String reason, String SQLState) {
    this(reason, SQLState, 0);
  }
  
  public SQLException(String reason, String SQLState, int vendorCode) {
    super(reason);
    this.SQLState = SQLState;
    this.vendorCode = vendorCode;
  }

  public int getErrorCode() {
    return vendorCode;
  }
  
  public SQLException getNextException() {
    return next;
  }

  public void setNextException(SQLException ex) {
    next = ex;
  }

  public String getSQLState() {
    return SQLState;
  }
  
}

