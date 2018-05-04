public class CubicCurves
{
  ArrayList<Vector> controlPoints;

  public CubicCurves(  ){
    
  }

  public void naturalSplines( ){
    //                            T
    // P(u) = ( x(u), y(u), z(u) )
    //               3          2
    // x(u) = a_x * u  + b_x * u  + c_x * u + d_x
    //               3          2
    // y(u) = a_y * u  + b_y * u  + c_y * u + d_y
    //               3          2
    // z(u) = a_z * u  + b_z * u  + c_z * u + d_z
    // *******************************************
    //             3        2
    // P(u) = a * u  + b * u  + c * u + d
    // 0 <= u <= 1
  }

  public void hermitSplines( ){
    //             3        2
    // P(u) = a * u  + b * u  + c * u + d
    // P_k = P( 0 ) = d
    // P_k = P( 1 ) = a + b + c + d
    // Dp_k = P'( 0 ) = c
    // Dp_k+1 = P'( 1 ) = ( 3a, 2b, c )
    // | a |    |  2 -2  1  1 |  |   P_k   |
    // | b | _  | -3  3 -2 -1 |  |  P_k+1  |
    // | c | -  |  0  0  1  0 |  |  Dp_k   |
    // | d |    |  1  0  0  0 |  | Dp_k+1  |
  }

  public void bezierSplines(){
    
  }
  

}