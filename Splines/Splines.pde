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

Scene scene;
Interpolator interpolator;
OrbitNode eye;
boolean drawGrid = true, drawCtrl = true;

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
    fill( 255, 0, 0 );
    stroke( 255, 0, 255 );
    for( Frame frame : interpolator.keyFrames( ) )
      scene.drawPickingTarget( (Node) frame );
  }else{
    fill( 255, 0, 0 );
    stroke( 255, 0, 255 );
    scene.drawPath( interpolator );
  }

  /**************************
   * Splines implementation *
   **************************/

  switch( mode ){
    case 0:
      //interpolator.keyFrames( );
      Vector[] points = new Vector[8];
      int l = 0;
      for( Frame frame : interpolator.keyFrames( ) ){
        points[l++] = frame.position( );
      }
      float dU = 0.002F;
      float[][] coefficients = curves.naturalCubicSpline( );
      //float[][] points2 = new float[3][8];
      for( int i = 0; i < curves.numCurves( ); i++ ){
        int k = (int)(1/dU) + 100;
        float[][] point = new float[3][k];
        for( float U = 0F, j = 0F; U <= 1.1F; U += dU, j += 1 ){
          float U3 = pow( U, 3 );
          float U2 = pow( U, 2 );
          float X = U3 * coefficients[0][i*4] + U2 * coefficients[0][(i*4)+1] + U * coefficients[0][(i*4)+2] + coefficients[0][(i*4)+3];
          float Y = U3 * coefficients[1][i*4] + U2 * coefficients[1][(i*4)+1] + U * coefficients[1][(i*4)+2] + coefficients[1][(i*4)+3];
          float Z = U3 * coefficients[2][i*4] + U2 * coefficients[2][(i*4)+1] + U * coefficients[2][(i*4)+2] + coefficients[2][(i*4)+3];
          /*println( i + 1, "   NumCurves: ", curves.numCurves( ) );
            println( "X: ", X, "  Y: ", Y ,"  Z: ", Z );
            println( "dxi: ", coefficients[0][(i*4)+3], "  dyi: ", coefficients[1][(i*4)+3], "  dzi: ", coefficients[2][(i*4)+3] );
            println( "  X: ", points[i+1].x( ), "  Y: ", points[i+1].y( ) ,"  Z: ", points[i+1].z( ) );*/
          
          point[0][(int)j] = X;
          point[1][(int)j] = Y;
          point[2][(int)j] = Z;
        }
        stroke( 255 );
        for( int p = 0; p < (int)(1/dU) - 1; p++ ){
          /*println( "k: ", k, "  p: ", p );*/
          line( point[0][p], point[1][p], point[2][p], point[0][p + 1], point[1][p + 1], point[2][p + 1] );
        }
      }
    break;
    case 1:
      curves.hermiteSpline( );
    break;
    case 2:
      curves.bezierSpline( 7 );
    break;
    case 3:
      curves.bezierSpline( 3 );
    break;
  }
}

void keyPressed( ){
  if( key == ' ' )
    if( mode < 3 ) mode++;
    else mode = 0;
  if( key == 'g' )
    drawGrid = !drawGrid;
  if( key == 'c' )
    drawCtrl = !drawCtrl;
}