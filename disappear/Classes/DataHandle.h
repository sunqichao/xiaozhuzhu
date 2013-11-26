//
//  DataHandle.h
//  disappear
//
//  Created by CpyShine on 13-5-29.
//  Copyright 2013年 CpyShine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#include "config.h"

@class DrawSprite;

@interface DataHandle : CCLayerColor {
    
    //储存所有的精灵
    NSMutableArray * m_drawSpriteArray;
    
    //当前选中的颜色
    ccColor4F m_currentDrawColor;
    
    //这个表示连接成功的数组
    NSMutableArray * m_stackArray;
    
    //是否开始画线
    BOOL m_drawLine;
    
    BOOL m_objectHasContina;
    
    BOOL m_removeAllSameColor;
    
    //是否使用必杀
    BOOL m_toolsDisappear;
    
    //必杀的类型，YES表示大必杀，会消除所选颜色的所有点，NO表示只消除选中的那个点
    BOOL m_toolsDisappearType;
    
    BOOL m_canPlaying;
    
    //当手触摸到屏幕上的那个点的坐标 画线的时候要用
    CGPoint m_movePos;
}

-(void) startAnimtionDisplay;

-(void) startPlaying;

//-(DrawSprite *)getCurrentSelectSprite:(CGPoint)pos color:(ccColor4F) color;

-(BOOL) touchBegine:(CGPoint) local;//touch begine

-(void) touchMove:(CGPoint) local; // touch moved

-(void) touchEnd;// touch 结束

-(void) disappearEnd;// 消除结束

-(BOOL) allDrawNodeBeSelected:(BOOL) disappearType;//全部选中

//-(void) cancelAllDrawNodeBeSelected;// 取消全部选中的情况

-(void) moveOut;
-(void) moveIn;

@end
