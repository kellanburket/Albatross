//
//  ClassReflektor.h
//  Reflektor
//
//  Created by Kellan Cummings on 6/13/15.
//  Copyright (c) 2015 Kellan Cummings. All rights reserved.
//

#ifndef Reflektor_ClassReflektor_h
#define Reflektor_ClassReflektor_h

@import Foundation;

@interface ClassReflektor : NSObject

+ (id)create:(NSString *)className;
+ (id)create:(NSString *)className initializer:(SEL)initializer argument:(id)argument;

@end

#endif
