import java.util.List;
import java.util.Arrays;

public class Curves
{
  private ArrayList<Vector> controlPoints;
  private float[] incognits;
  private float[] valuesX;
  private float[] valuesY;
  private float[] valuesZ;
  private float[][] matrix;

  public Curves( List<Frame> frames ){
    controlPoints = new ArrayList( );
    for( Frame frame : frames ){
      controlPoints.add( frame.position( ) );
    }
    incognits = null;
  }

  public List<Float> naturalCubicSpline( int curve ){
    if( curve > numCurves( ) || curve < 0 )
      throw new IllegalArgumentException( "The parameter must be: 0 <= param <= numCurves" );
    if( incognits == null ){
      // number of incognits
      int numIncognits = (controlPoints.size( ) - 1) * 4;
      incognits = new float[numIncognits * 3];
      valuesX = new float[ numIncognits ];
      valuesY = new float[ numIncognits ];
      valuesZ = new float[ numIncognits ];
      matrix = new float[numIncognits][numIncognits];
      for( int i = 0; i < numIncognits; i++ ){
        for( int j = 0; j < numIncognits; j++ ){
          matrix[i][j] = 0F; 
        }
      }
      this.solve( );
    }
    List<Float> coefficientCurve = new ArrayList( 12 );
    for( int i = 0; i < 4; i++ ){
      coefficientCurve.add( incognits[i + curve] );
      coefficientCurve.add( incognits[i + curve + (numCurves( ) * 4)] );
      coefficientCurve.add( incognits[i + curve + (numCurves( ) * 8)] );
    }
    return coefficientCurve;
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
    this.createResults( );
    this.invertMatrix( );
    this.findIncognits( );
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

  private void createResults( ){
    int numCurves = (controlPoints.size( ) - 1);
    for( int i = 0; i < numCurves; i++ ){
      valuesX[(i * 2)] = controlPoints.get( i ).x( );
      valuesX[(i * 2) + 1] = controlPoints.get( i + 1 ).x( );
      valuesY[(i * 2)] = controlPoints.get( i ).y( );
      valuesY[(i * 2) + 1] = controlPoints.get( i + 1 ).y( );
      valuesZ[(i * 2)] = controlPoints.get( i ).z( );
      valuesZ[(i * 2) + 1] = controlPoints.get( i + 1 ).z( );
    }
    for( int i = numCurves * 2; i < numCurves * 4; i += 2 ){
      valuesX[i] = 0;
      valuesX[i + 1] = 0;
      valuesY[i] = 0;
      valuesY[i + 1] = 0;
      valuesZ[i] = 0;
      valuesZ[i + 1] = 0;
    }
    return;
  }

  private void invertMatrix( ){
    // create identity matrix to work in inverse metrix
    float[][] invert = new float[matrix.length][matrix.length];
    for( int i = 0; i < matrix.length; i++ )
      for( int j = 0; j < matrix.length; j++ )
        if( i != j )
          invert[i][j] = 0F;
        else
          invert[i][j] = 1F;
    // Iterate to find inverse matrix
    for( int i = 0; i < matrix.length; i++ ){
      if( matrix[i][i] == 0F ){
          pivote( i, invert );
      }
      for( int j = 0; j < matrix.length; j++ ){
        if( j != i ){
          if( matrix[j][i] != 0F )
            gauss( i, j, invert );
        }
      }
    }
    convertToIdentity( invert );
    matrix = invert;
  }

  private void pivote( int pos, float[][] invert ){
    int i = pos + 1;
    while( i < matrix.length && matrix[i][pos] == 0F ){
      i++;
    }
    if( i == matrix.length ){
      println( "Is not posible find the inverse of matrix" );
      exit( );
    }
    float[] temp = matrix[pos];
    matrix[pos] = matrix[i];
    matrix[i] = temp;
    temp = invert[pos];
    invert[pos] = invert[i];
    invert[i] = temp;
    float temp1 = valuesX[pos];
    valuesX[pos] = valuesX[i];
    valuesX[i] = temp1;
    temp1 = valuesY[pos];
    valuesY[pos] = valuesY[i];
    valuesY[i] = temp1;
    temp1 = valuesZ[pos];
    valuesZ[pos] = valuesZ[i];
    valuesZ[i] = temp1;
    //drawMatrix();
    return;
  }

  private void gauss( int ref, int conv, float[][] invert ){
    float const1 = matrix[ref][ref];
    float const2 = matrix[conv][ref];
    for( int i = 0; i < matrix.length; i++ ){
      matrix[conv][i] *= const1;
      matrix[conv][i] -= (const2 * matrix[ref][i]);
      invert[conv][i] *= const1;
      invert[conv][i] -= (const2 * invert[ref][i]);
    }
  }

  private void convertToIdentity( float[][] invert ){
    for( int i = 0; i < matrix.length; i++ ){
      float div = matrix[i][i];
      matrix[i][i] /= div;
      for( int j = 0; j < matrix.length; j++ ){
        matrix[i][j] *= matrix[i][j];
        invert[i][j] /= div;
      }
    }
  }

  private void findIncognits( ){
    int numIncognits = (controlPoints.size( ) - 1) * 4;
    for( int i = 0; i < numIncognits; i++ ){
      float[] sum = {0F, 0F, 0F};
      for( int j = 0; j < numIncognits; j++ ){
        sum[0] += matrix[i][j] * valuesX[j];
        sum[1] += matrix[i][j] * valuesY[j];
        sum[2] += matrix[i][j] * valuesZ[j];
      }
      incognits[i] = sum[0];
      incognits[i + numIncognits] = sum[1];
      incognits[i + (2 * numIncognits)] = sum[2];
    }
  }

  private void drawMatrix( ){
    for( int l = 0; l < matrix.length; l++ ){
      for( int p = 0; p < matrix.length; p++ ){
        print( matrix[l][p] );
        print( "  " );
      }
      println(  );
    }
  }

  private void drawMatrix( float[][] matrix ){
    for( int l = 0; l < matrix.length; l++ ){
      for( int p = 0; p < matrix.length; p++ ){
        print( matrix[l][p] );
        print( "  " );
      }
      println(  );
    }
  }

  public int numControlPoints( ){
    return controlPoints.size( );
  };
  
  public int numCurves( ){
    return numControlPoints( ) - 1;
  }

}