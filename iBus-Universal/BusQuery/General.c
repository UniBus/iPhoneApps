/*
 *  General.c
 *  StopQuery
 *
 *  Created by Zhenwang Yao on 16/08/08.
 *  Copyright 2008 Zhenwang Yao. All rights reserved.
 *
 */

#include "General.h"
#include <math.h>
#include <stdio.h>

#define PI				3.141592654
#define EARTH_RADIUS	6370.997// unit=Km, if using mile radius = 3958.754
#define DEG2RAD			(PI/180.0)
#define RAD2DEG			(180.0/PI)

/*! 
 * \brief Compute distance between two coordinate.
 *
 * This function was modified from some code segment I found on the Internet. 
 *    This function computes the distance between two points on the
 *    surface of the (spherical) earth.  The points are specified in
 *    geographic coordinates (lat1,lon1) and (lat2,lon2).  The algorithm
 *    used here is taken directly from ELEMENTS OF CARTOGRAPHY, 4e. -
 *    Robinson, Sale, Morrison - John Wiley & Sons, Inc. - pp. 44-45.
 *    Geometrically, the function computes the arc distance dtheta on
 *    the sphere between two points A and B by the following formula:
 *
 *           \f[\cos(\Delta\theta) = (\sin a \sin b) + (\cos a \cos b \cos p)\f]
 *
 *              where:
 *                 - \f$\Delta\theta\f$ = arc distance between A and B
 *                 - a = latitude of A
 *                 - b = latitude of B
 *                 - p = degrees of longitude between A and B
 *
 *    Once the arc distance is determined, it is converted into miles by
 *    taking the ratio between the circumference of the earth (2*PI*R) and
 *    the number of degrees in a circle (360):
 *		
 *			\f[\textrm{distance} = \Delta\theta \cdot({\textrm{earth's circumference}})\f]
 *
 *   The calculated distance is also referred to as the Great Circle.
 *
 * \param (lat1, lon1) The coordinate of the first position.
 * \param (lat2, lon2) The coordinate of the first position.
 * \return distance between the two given coordinates.
 *
 */
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

/*! 
 * \brief Compute distance in latitude to achieve the given distance, on the same longitude.
 *
 * \param dist desired distance
 * \param lat This is actually no use.
 * \param lon This is actually no use, either.
 * \return distance in latitude to achieve the given distance
 */
float deltaLat(double lat, double lon, double dist)
{
	//printf("acos(%f) = %f", dist / (EARTH_RADIUS * lon*DEG2RAD), acos(dist / (EARTH_RADIUS * lon*DEG2RAD) ));
	//printf("RAD2DEG * acos(dist / (EARTH_RADIUS * lon*DEG2RAD) = %f", RAD2DEG * acos(dist / (EARTH_RADIUS * lon*DEG2RAD) ));
	return RAD2DEG * (dist / EARTH_RADIUS );
}

/*! 
 * \brief Compute distance in latitude to achieve the given distance, on the same longitude.
 *
 * \param dist Desired distance
 * \param lat Along the same latitude.
 * \param lon This is actually no use, either.
 * \return distance in longitude to achieve the given distance
 */
float deltaLon(double lat, double lon, double dist)
{
	return RAD2DEG * dist / (EARTH_RADIUS * cos(lat*DEG2RAD) );
}

/*!
 * \brief Unit conversion.
 *
 * \param unit 
 *		- UNIT_MI mile
 *		- UNIT_KM km
 * \return Actual distance in KM
 */
double UnitToKm(int unit)
{
	if (unit == UNIT_MI)
		return 1.609;
	else 
		return 1.0;
		//NSAssert1(NO, @"Unknow current unit!");
}

/*! 
 * \brief Unit naming.
 *
 * \param unit 
 *		- UNIT_MI mile
 *		- UNIT_KM km
 * \return Name of the given unit.
 */
char* UnitName(int unit)
{
	if (unit == UNIT_MI)
		return "Mi";
	else
		return "Km";
}
