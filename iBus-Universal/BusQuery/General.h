/*
 *  General.h
 *  StopQuery
 *
 *  Created by Zhenwang Yao on 16/08/08.
 *  Copyright 2008 Zhenwang Yao. All rights reserved.
 *
 */

float distance( double lat1, double lon1, double lat2, double lon2);
float deltaLat(double lat, double lon, double dist);
float deltaLon(double lat, double lon, double dist);

#define UNIT_KM		0
#define UNIT_MI		1
double UnitToKm(int unit);
