//
//  ARKitHelper.swift
//  Tailgate
//
//  Created by Michael Onjack on 6/25/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import CoreLocation
import SceneKit

extension FloatingPoint {
    func toRadians() -> Self {
        return self * .pi / 180
    }
    
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
}



//////////////////////////////////////////////////////////////////////////////////////
//
// rotateAroundY
//
//
//
func rotateAroundY(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
    var matrix = matrix
    
    let radians = degrees.toRadians()
    
    matrix.columns.0.x = cos(radians)
    matrix.columns.0.z = -sin(radians)
    
    matrix.columns.2.x = sin(radians)
    matrix.columns.2.z = cos(radians)
    
    //the method returns the inverse of the matrix because rotations in ARKit are counterclockwise
    return matrix.inverse
}



//////////////////////////////////////////////////////////////////////////////////////
//
// rotateAroundX
//
//
//
func rotateAroundX(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
    var matrix = matrix
    
    let radians = degrees.toRadians()
    
    matrix.columns.1.y = cos(radians)
    matrix.columns.1.z = sin(radians)
    
    matrix.columns.2.y = -sin(radians)
    matrix.columns.2.z = cos(radians)
    
    // the method returns the inverse of the matrix because rotations in ARKit are counterclockwise
    return matrix.inverse
}



//////////////////////////////////////////////////////////////////////////////////////
//
// rotateAroundZ
//
//
//
func rotateAroundZ(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
    var matrix = matrix
    
    let radians = degrees.toRadians()
    
    matrix.columns.0.x = cos(radians)
    matrix.columns.0.y = sin(radians)
    
    matrix.columns.1.x = -sin(radians)
    matrix.columns.1.y = cos(radians)
    
    // the method returns the inverse of the matrix because rotations in ARKit are counterclockwise
    return matrix
}



//////////////////////////////////////////////////////////////////////////////////////
//
// bearingBetweenLocations
//
//
//
func bearingBetweenLocations(_ originLocation: CLLocation, _ driverLocation: CLLocation) -> Double {
    let lat1 = originLocation.coordinate.latitude.toRadians()
    let lon1 = originLocation.coordinate.longitude.toRadians()
    
    let lat2 = driverLocation.coordinate.latitude.toRadians()
    let lon2 = driverLocation.coordinate.longitude.toRadians()
    
    let longitudeDiff = lon2 - lon1
    
    let y = sin(longitudeDiff) * cos(lat2);
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(longitudeDiff);
    
    var degrees = atan2(y, x).toDegrees()
    if degrees < 0 {
        degrees = degrees + 360
    }
    
    return degrees
}
