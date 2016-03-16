//
//  UIKitMacros.h
//  MoodRadioStation
//
//  Created by Minor on 16/2/29.
//  Copyright © 2016年 Minor. All rights reserved.
//

#ifndef UIKitMacros_h
#define UIKitMacros_h

#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define Font(x)                         [UIFont systemFontOfSize : x]
#define ItalicFont(x)                   [UIFont italicSystemFontOfSize:x]
#define BoldFont(x)                     [UIFont boldSystemFontOfSize : x]

#define scaleFactorBaseiPhone6 (SCREEN_WIDTH / 375.0)

// sample: Designer - #FF0000, We - HEXCOLOR(0xFF0000)
#define HEXCOLOR(hexValue)              [UIColor colorWithRed : ((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0 green : ((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0 blue : ((CGFloat)(hexValue & 0xFF)) / 255.0 alpha : 1.0]

#define HEXACOLOR(hexValue, alphaValue) [UIColor colorWithRed : ((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0 green : ((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0 blue : ((CGFloat)(hexValue & 0xFF)) / 255.0 alpha : (alphaValue)]

#define RGBCOLOR(r, g, b)               [UIColor colorWithRed : (r) / 255.0f green : (g) / 255.0f blue : (b) / 255.0f alpha : 1]

#endif /* UIKitMacros_h */
