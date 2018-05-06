import java.util.List;
import java.util.Arrays;

public class Curves
{
  public ArrayList<Vector> controlPoints;
  public float[][] incognits;
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

  public float[][] naturalCubicSpline( ){
    if( incognits == null ){
      // number of incognits
      int numIncognits = (controlPoints.size( ) - 1) * 4;
      incognits = new float[3][numIncognits];
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
    return incognits;
  }

  public float[][][] hermiteSpline( ){
    float[][][] coefficients = new float[this.numCurves( )][3][4];
    for( int i = 0; i < this.numCurves( ); i++ ){
      for( int j = 0; j < 3; j++ ){
        // Coefficients for the polinomio i in X, Y and Z
        coefficients[i][j][0] = incognits[j][(i * 4) + 3]; // pk = d
        coefficients[i][j][1] = incognits[j][(i * 4)] + incognits[j][(i * 4) + 1] + incognits[j][(i * 4) + 2] + incognits[j][(i * 4) + 3]; // pk+1 = a + b + c
        coefficients[i][j][2] = incognits[j][(i * 4) + 2]; // Dpk = c
        coefficients[i][j][3] = 3 * incognits[j][(i * 4)] + 2 * incognits[j][(i * 4) + 1] + incognits[j][(i * 4) + 2]; // Dpk+1 = 3a + 2b + c
      }
    }
    return coefficients;
  }

  public void bezierSpline( int degree ){
    
  }

  private void solve( ){
    // Matrix
    this.createMatrix( );
    this.invertMatrix( );
    this.findIncognits( );
  }

  private void createMatrix( ){
    int indexC = 0;
    int numCurves = this.controlPoints.size( ) - 1;
    // 2n ecuations
    for( int i = 0; i < numCurves * 2; i += 2, indexC += 4 ){
      float[] aux1 = matrix[i];
      float[] aux2 = matrix[i + 1];
      for( int j = indexC; j < indexC + 4; j++ ){
        if( j == indexC + 3 ){
          aux1[j] = 1F;
          aux2[j] = 1F;
        }else{
          aux2[j] = 1F;           
        }
      }
      Vector controlPoint1 = controlPoints.get( (int)(i/2) );
      Vector controlPoint2 = controlPoints.get( (int)(i/2) + 1 );
      valuesX[i] = controlPoint1.x( );
      valuesX[i + 1] = controlPoint2.x( );
      valuesY[i] = controlPoint1.y( );
      valuesY[i + 1] = controlPoint2.y( );
      valuesZ[i] = controlPoint1.z( );
      valuesZ[i + 1] = controlPoint2.z( );
    }
    // 2n - 2 ecuations
    indexC = 0;
    for( int i = numCurves * 2; i < (4 * numCurves) - 2; i++, indexC += 4 ){
      float[] aux1 = matrix[i];
      float[] aux2 = matrix[++i];
      // ---------------
      aux1[indexC] = 3F;
      aux2[indexC] = 6F;
      // ---------------
      aux1[indexC + 1] = 2F;
      aux2[indexC + 1] = 2F;
      aux2[indexC + 5] = -2F;
      // ---------------
      aux1[indexC + 2] = 1F;
      aux1[indexC + 6] = -1F;
      // ----------------
      valuesX[i] = 0;
      valuesX[i + 1] = 0;
      valuesY[i] = 0;
      valuesY[i + 1] = 0;
      valuesZ[i] = 0;
      valuesZ[i + 1] = 0;
    }

    // 2 ecuations
    float[] aux1 = matrix[(4 * numCurves) - 2];
    float[] aux2 = matrix[(4 * numCurves) - 1];
    aux1[1] = 2F;
    aux2[numCurves * 4 - 4] = 6F;
    aux2[numCurves * 4 - 3] = 2F;
    valuesX[numCurves * 4 - 2] = 0;
    valuesX[numCurves * 4 - 1] = 0;
    valuesY[numCurves * 4 - 2] = 0;
    valuesY[numCurves * 4 - 1] = 0;
    valuesZ[numCurves * 4 - 2] = 0;
    valuesZ[numCurves * 4 - 1] = 0;

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
      incognits[0][i] = sum[0];
      incognits[1][i] = sum[1];
      incognits[2][i] = sum[2];
    }
  }

  private void drawMatrix( ){
    for( int l = 0; l < matrix.length; l++ ){
      for( int p = 0; p < matrix.length; p++ ){
        print( matrix[l][p] );
        print( "," );
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