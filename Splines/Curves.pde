import java.util.List;

public class Curves
{
  private ArrayList<Vector> controlPoints;
  private ArrayList<Float> incognits;
  private ArrayList<Float> values;
  private float[][] matrix;

  public Curves( List<Frame> frames ){
    controlPoints = new ArrayList( );
    for( Frame frame : frames ){
      controlPoints.add( frame.position( ) );
    }
    incognits = null;
  }

  public ArrayList<Float> naturalCubicSpline( ){
    if( incognits == null ){
      // number of incognits
      int numIncognits = (controlPoints.size( ) - 1) * 4;
      incognits = new ArrayList( numIncognits * 3 );
      values = new ArrayList( numIncognits );
      matrix = new float[numIncognits][numIncognits];
      for( int i = 0; i < numIncognits; i++ ){
        for( int j = 0; j < numIncognits; j++ ){
          matrix[i][j] = 0F; 
        }
      }
      this.solve( );
    }
    return incognits;
  }

  public void hermiteSpline( ){
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

  public void bezierSpline( int degree ){
    
  }

  private void solve( ){
    // Matrix
    this.createMatrix( );
    this.invertMatrix( );
    this.createResults( );
    for( int i = 0; i < 0; i++ );
  }

  private void createMatrix( ){
    int indexC = 0;
    int numCurves = this.controlPoints.size( ) - 1;
    // 2n ecuations
    for( int i = 0; i < numCurves * 2; i++, indexC += 4 ){
      float[] aux1 = matrix[i];
      float[] aux2 = matrix[++i];
      for( int j = indexC; j < indexC + 4; j++ ){
        if( j == indexC + 3 ){
          aux1[j] = 1F;
          aux2[j] = 1F;
        }else{
          aux2[j] = 1F;           
        }
      }
    }
    // 2n - 2 ecuations
    indexC = 0;
    for( int i = numCurves * 2; i < (4 * numCurves) - 2; i++, indexC += 4 ){
      float[] aux1 = matrix[i];
      float[] aux2 = matrix[++i];
      for( int j = indexC; j < indexC + 3; j++ ){
        if( j == indexC ){
          aux1[j] = 3F;
          aux2[j] = 6F;
          aux1[j + 4] = -3F;
          aux2[j + 4] = -6F;
        }else if( j == indexC + 1 ){
          aux1[j] = 2F;
          aux2[j] = 2F;
          aux1[j + 4] = -2F;
          aux2[j + 4] = -2F;
        }else{
          aux1[j] = 1F;
          aux1[j + 4] = -1F;
        }
      }
    }

    // 2 ecuations
    float[] aux1 = matrix[(4 * numCurves) - 2];
    float[] aux2 = matrix[(4 * numCurves) - 1];
    aux1[0] = 6F;
    aux2[0] = 0F;
    aux1[1] = 2F;
    aux2[1] = 0F;
    aux1[numCurves * 4 - 2] = 0F;
    aux2[numCurves * 4 - 2] = 6F;
    aux1[numCurves * 4 - 1] = 0F;
    aux2[numCurves * 4 - 1] = 2F;
    indexC += 4;

  }

  public void invertMatrix( ){
    this.matrix = multiplicar( 1F / determinante( matrix ), adjunta( ) );
  }

  public void createResults( ){
    
  }

  public float[][] multiplicar( float n, float[][] matrix ){
    for( int i = 0; i < matrix.length; i++ )
      for( int j = 0; j < matrix.length; j++ )
        matrix[i][j] *= n;
    return matrix;
  }

  public float[][] adjunta( ){
    return transpuesta( coefactores( ) );
  }

  private float[][] coefactores( ){
    float[][] coefactores = new float[matrix.length][matrix.length];
    for( int i = 0; i < matrix.length; i++ ){
      for( int j = 0; j < matrix.length; j++ ){
        // ----------------------------------------------
        float[][] subMatrix = new float[matrix.length - 1][matrix.length - 1];
        boolean passi = false;
        for( int m = 0; m < matrix.length; m++ ){
          if( m != i ){
            boolean passj = false;
            for( int n = 0; n < matrix.length; n++ ){
              if( n != j ){
                int xi = m;
                int xj = n;
                if( passi )
                  xi -= 1;
                if( passj )
                  xj -= 1;
                subMatrix[xi][xj] = matrix[m][n];
              }else
                passj = true;
            }
          }else
            passi = true;
        }
        if( (i + j) % 2 == 0 )
          coefactores[i][j] = determinante( subMatrix );
        else
          coefactores[i][j] = -determinante( subMatrix );
      }
    }
    return coefactores;
  }

  public float[][] transpuesta( float[][] matrix ){
    float[][] matrixT = new float[matrix[0].length][matrix.length];
    for( int i = 0; i < matrix.length; i++ ){
      for( int j = 0; j < matrix.length; j++ )
        matrixT[i][j] = matrix[j][i];
    }
    return matrixT;
  }

  private float determinante( float[][] matriz ){
    float det;
    if( matriz.length == 2 ){
      det = (matriz[0][0] * matriz[1][1]) - (matriz[1][0] * matriz[0][1]);
      return det;
    }
    float suma = 0;
    for( int h = 0; h < matriz.length; h++ ){
      float[][] subMatrix = new float[matriz.length - 1][matriz.length - 1];
      for( int i = 1; i < matriz.length; i++ ){
        boolean pass = false;
        for( int j = 0; j < matriz.length; j++ ){
          if( j != h )
            if( pass )
              subMatrix[i - 1][j - 1] = matriz[i][j];
            else
              subMatrix[i - 1][j] = matriz[i][j];
          else
            pass = true;
        }
      }
      if( h % 2 == 0 )
        suma += matriz[0][h] * determinante( subMatrix );
      else
        suma -= matriz[0][h] * determinante( subMatrix );
    }
    return suma;
  }


}