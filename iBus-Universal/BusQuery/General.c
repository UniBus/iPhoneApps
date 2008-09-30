/*
 *  General.c
 *  StopQuery
 *
 *  Created by Zhenwang Yao on 16/08/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "General.h"
#include <math.h>
#include <stdio.h>
/*************************************************************************
 *
 *N  distance
 *
 *::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 *
 *   Purpose:
 *P
 *    This function computes the distance between two points on the
 *    surface of the (spherical) earth.  The points are specified in
 *    geographic coordinates (lat1,lon1) and (lat2,lon2).  The algorithm
 *    used here is taken directly from ELEMENTS OF CARTOGRAPHY, 4e. -
 *    Robinson, Sale, Morrison - John Wiley & Sons, Inc. - pp. 44-45.
 *    Geometrically, the function computes the arc distance dtheta on
 *    the sphere between two points A and B by the following formula:
 *
 *              cos dtheta = (sin a sin b) + (cos a cos b cos p)
 *
 *              where:
 *
 *                 dtheta = arc distance between A and B
 *                 a = latitude of A
 *                 b = latitude of B
 *                 p = degrees of longitude between A and B
 *
 *    Once the arc distance is determined, it is converted into miles by
 *    taking the ratio between the circumference of the earth (2*PI*R) and
 *    the number of degrees in a circle (360):
 *
 *        distance in miles (d)            arc distance in degrees (dtheta)
 *   ------------------------------   =    --------------------------------
 *   earth's circumference in miles        earth's circumference in degrees
 *
 *                                    or
 *
 *    d = (dtheta * (2*PI*R)) / 360  =>
 *    d = (dtheta*PI*R)/180
 *
 *   The calculated distance is also referred to as the Great Circle.
 *
 *E
 *::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 *
 *   Parameters:
 *A
 *    lat1  <input> == (double) latitude of point A.
 *    lon1  <input> == (double) longitude of point A.
 *    lat2  <input> == (double) latitude of point B.
 *    lon2  <input> == (double) longitude of point B.
 *    units <input> == (int) flag to indicate output distance units.
 *                          0 -> Miles, 1 -> Kilometers
 *E
 *::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 *
 *   History:
 *H
 *    Barry Michaels   November 1990   Original Version   DOS Turbo C
 *    Added kilometers option - May 1991 - BJM
 *E
 *************************************************************************/
#define PI				3.141592654
#define EARTH_RADIUS	6370.997// unit=Km, if using mile radius = 3958.754
#define DEG2RAD			(PI/180.0)
#define RAD2DEG			(180.0/PI)

float distance( double lat1, double lon1, double lat2, double lon2)
{
	double a,b,p,dtheta,d;
	double radius=  EARTH_RADIUS;
	
	if (lat1 > 90.0) lat1 -= 180.0;
	if (lat2 > 90.0) lat2 -= 180.0;
	
	a = lat1*DEG2RAD;  /* Degrees must be converted to radians */
	b = lat2*DEG2RAD;
	p = fabs(lon1-lon2)*DEG2RAD;
	dtheta = (sin(a)*sin(b)) + (cos(a)*cos(b)*cos(p));
	dtheta = acos(dtheta)*RAD2DEG;   /* Compute arc distance in degrees */
	d = (dtheta*PI*radius)/180.0;  /* Compute distance in miles or km */
	return d;
}

float deltaLat(double lat, double lon, double dist)
{
	//printf("acos(%f) = %f", dist / (EARTH_RADIUS * lon*DEG2RAD), acos(dist / (EARTH_RADIUS * lon*DEG2RAD) ));
	//printf("RAD2DEG * acos(dist / (EARTH_RADIUS * lon*DEG2RAD) = %f", RAD2DEG * acos(dist / (EARTH_RADIUS * lon*DEG2RAD) ));
	return RAD2DEG * (dist / EARTH_RADIUS );
}

float deltaLon(double lat, double lon, double dist)
{
	return RAD2DEG * dist / (EARTH_RADIUS * cos(lat*DEG2RAD) );
}
