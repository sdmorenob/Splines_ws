/**
 * Splines.
 *
 * Here we use the interpolator.keyFrames() nodes
 * as control points to render different splines.
 *
 * Press ' ' to change the spline mode.
 * Press 'g' to toggle grid drawing.
 * Press 'c' to toggle the interpolator path drawing.
 */

import frames.input.*;
import frames.primitives.*;
import frames.core.*;
import frames.processing.*;

// global variables
// modes: 0 natural cubic spline; 1 Hermite;
// 2 (degree 7) Bezier; 3 Cubic Bezier
int mode;
Curves curves;
int control_points = 8;
boolean modify = true;
Frame[] point = new Frame[control_points];

Scene scene;
Interpolator interpolator;
OrbitNode eye;
boolean drawGrid = false, drawCtrl = true;

//Choose P3D for a 3D scene, or P2D or JAVA2D for a 2D scene
String renderer = P3D;

void setup( ){
  size( 700, 700, renderer );
  scene = new Scene( this );
  eye = new OrbitNode( scene );
  eye.setDamping( 0 );
  scene.setEye( eye );
  scene.setFieldOfView( PI / 3 );
  //interactivity defaults to the eye
  scene.setDefaultGrabber( eye );
  scene.setRadius( 150 );
  scene.fitBallInterpolation( );
  interpolator = new Interpolator( scene, new Frame( ) );
  // framesjs next version, simply go:
  //interpolator = new Interpolator(scene);

  // Using OrbitNodes makes path editable
  for( int i = 0; i < 8; i++ ){
    Node ctrlPoint = new OrbitNode( scene );
    ctrlPoint.randomize( );
    point[i] = (Frame)ctrlPoint;
    interpolator.addKeyFrame( ctrlPoint );
  }

  mode = 0;
  curves = new Curves( interpolator.keyFrames( ) );

}

void draw( ){
  background( 175 );
  if( drawGrid ){
    stroke( 255, 255, 0 );
    scene.drawGrid( 200, 50 );
  }
  if( drawCtrl ){
    fill( 255, 255, 255 );
    stroke( 255, 255, 255 );
    for( Frame frame : interpolator.keyFrames( ) )
      scene.drawPickingTarget( (Node) frame );
  }else{
    fill( 255, 255, 255 );
    strokeWeight( 2 );
    stroke( 255, 255, 255 );
    scene.drawPath( interpolator );
  }

  /**************************
   * Splines implementation *
   **************************/

  float dU = 0.002F;
  switch( mode ){
    // Begin natural cubic splines implementation
    case 0:
      float[][] coefficients;
      coefficients = curves.naturalCubicSpline( );
      for( int i = 0; i < curves.numCurves( ); i++ ){
        int k = (int)(1/dU) + (int)((1/dU)*0.2);
        float[][] point = new float[3][k];
        for( float U = 0F, j = 0F; U <= 1F; U += dU, j += 1 ){
          float U3 = pow( U, 3 );
          float U2 = pow( U, 2 );
          float X = U3 * coefficients[0][i*4] + U2 * coefficients[0][(i*4)+1] + U * coefficients[0][(i*4)+2] + coefficients[0][(i*4)+3];
          float Y = U3 * coefficients[1][i*4] + U2 * coefficients[1][(i*4)+1] + U * coefficients[1][(i*4)+2] + coefficients[1][(i*4)+3];
          float Z = U3 * coefficients[2][i*4] + U2 * coefficients[2][(i*4)+1] + U * coefficients[2][(i*4)+2] + coefficients[2][(i*4)+3];

          point[0][(int)j] = X;
          point[1][(int)j] = Y;
          point[2][(int)j] = Z;
        }
        strokeWeight( 3 );
        fill( 102, 255, 57 );
        stroke( 102, 255, 57 );
        for( int p = 0; p < (int)(1/dU) - 1; p++ ){
          line( point[0][p], point[1][p], point[2][p], point[0][p + 1], point[1][p + 1], point[2][p + 1] );
        }
        strokeWeight( 1 );
      }
      scene.beginScreenCoordinates( );
      fill( 102, 255, 57 );
      textSize(25);
      text("Naturals", 30, 40);
      scene.endScreenCoordinates();
    break;
    // End natural cubic splines implementation
    // Begin Hermite spline implementation
    case 1:
      float[][][]coefficientsH = curves.hermiteSpline( );
      for( int i = 0; i < curves.numCurves( ); i++ ){
        int k = (int)(1/dU) + 100;
        float[][] point = new float[3][k];
        for( float U = 0F, j = 0F; U <= 1F; U += dU, j += 1 ){
          float U3 = pow( U, 3 );
          float U2 = pow( U, 2 );
          float H0 = (2 * U3) - (3 * U2) + 1;
          float H1 = (-2 * U3) + (3 * U2);
          float H2 = U3 - (2 * U2) + U;
          float H3 = U3 - U2;
          float X = coefficientsH[i][0][0] * H0 + coefficientsH[i][0][1] * H1 + coefficientsH[i][0][2] * H2 + coefficientsH[i][0][3] * H3;
          float Y = coefficientsH[i][1][0] * H0 + coefficientsH[i][1][1] * H1 + coefficientsH[i][1][2] * H2 + coefficientsH[i][1][3] * H3;
          float Z = coefficientsH[i][2][0] * H0 + coefficientsH[i][2][1] * H1 + coefficientsH[i][2][2] * H2 + coefficientsH[i][2][3] * H3;
          point[0][(int)j] = X;
          point[1][(int)j] = Y;
          point[2][(int)j] = Z;
        }
        strokeWeight( 3 );
        fill( 57, 255, 237 );
        stroke( 57, 255, 237 );
        for( int p = 0; p < (int)(1/dU) - 1; p++ ){
          line( point[0][p], point[1][p], point[2][p], point[0][p + 1], point[1][p + 1], point[2][p + 1] );
        }
        strokeWeight( 1 );
      }
      scene.beginScreenCoordinates( );
      fill( 57, 255, 237 );
      textSize(25);
      text("Hermite", 30, 40);
      scene.endScreenCoordinates();
    break;
    // End Hermite spline implementation

    case 2:
      stroke( 28, 40, 51 );
      strokeWeight(3);
      control_points = 4;
      curves.transform( control_points, point );
      scene.beginScreenCoordinates( );
      fill( 28, 40, 51 );
      textSize(25);
      text("Bezier 3G", 30, 40);
      scene.endScreenCoordinates( );
    break;

    case 3:
      fill( 239, 99, 99 );
      stroke( 239, 99, 99 );
      strokeWeight(3);
      control_points = 8;
      curves.transform( control_points, point );
      scene.beginScreenCoordinates( );
      fill( 239, 99, 99 );
      textSize(25);
      text("Bezier 7G", 30, 40);
      scene.endScreenCoordinates();
    break;
  }
}

void keyPressed( ){
  if( key == ' ')
    if( mode < 3 ){
      mode++;
      if( mode > 1 )
        drawCtrl = false;
    }else{
      mode = 0;
      drawCtrl = true;
    }
  if( key == 'g' )
    drawGrid = !drawGrid;
  if( key == 'c' )
    drawCtrl = !drawCtrl;
}