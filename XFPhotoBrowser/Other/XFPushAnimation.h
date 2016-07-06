//
//  XFPushAnimation.h
//  WangXingren
//
//  Created by zeroLu on 16/7/6.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFPushAnimation : NSObject
+ (CATransition *)getAnimation:(NSInteger)mytag direction:(int)direction;
@end
