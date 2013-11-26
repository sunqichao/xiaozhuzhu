//
//  DrawSprite.m
//  disappear
//
//  Created by CpyShine on 13-5-29.
//  Copyright 2013年 CpyShine. All rights reserved.
//
#include "DataHandle.h"
#import "DrawSprite.h"

#define caleActiontag 100

@implementation DrawSprite

@synthesize m_x;
@synthesize m_y;
@synthesize m_color;
@synthesize m_disappear;
@synthesize sprintFile;

-(CGPoint) calcPos:(NSInteger)x y:(NSInteger) y{
    
    CGFloat width = [self anchorPoint].x * m_w + x * m_w +addWidth;
    CGFloat height = [self anchorPoint].y * m_h + y * m_h +AddHeigh;
    return ccp(width, height);
}

-(void) calcColor{
    int type = arc4random()%TOTAL_TYPE;
    switch (type) {
        case 0:
            m_color = ccc4fBlue;
            self.sprintFile = @"Images/blueBao.png";
            break;
        case 1:
            m_color = ccc4fGreen;
            self.sprintFile = @"Images/greenBao.png";

            break;
        case 2:
            m_color = ccc4fRed;
            self.sprintFile = @"Images/pinkBao.png";

            break;
        case 3:
            m_color = ccc4fPurple;
            self.sprintFile = @"Images/purpleBao.png";

            break;
        case 4:
            m_color = ccc4fYellow;
            self.sprintFile = @"Images/yellowBao.png";
            
            break;
            
        default:
            m_color = ccc4fPurple;
            self.sprintFile = @"Images/purpleBao.png";

            break;
    }
}

-(void)spawnAtX:(NSInteger)x Y:(NSInteger)y Width:(CGFloat)w Height:(CGFloat)h{
    
    m_hasSelected = YES;
    m_disappear = NO;
    m_x = x;
    m_y = y;
    
    m_w = w*2;
    m_h = h*2;
    
    //创建出点的颜色
    [self calcColor];
    
//    [self setContentSize:CGSizeMake(DRAWSPRITE_RADIUES, DRAWSPRITE_RADIUES)];
    
    CGSize size = [CCDirector sharedDirector].winSize;
    
    //计算出每个点下落的的x坐标
    CGFloat wd = [self anchorPoint].x * m_w + x * m_w+addWidth;
    
    //画点用的
    m_drawNode = [CCDrawNode node];
    
    //设置位置 size.height指的是点下落的那个高度  wd指的是下落时x轴的位置，如果wd设置为固定的值100则就会从一个点下落
    [m_drawNode setPosition:ccp(wd, size.height)];
    
    //设置原点物理大小
    [m_drawNode setContentSize:CGSizeMake(DRAWSPRITE_RADIUES, DRAWSPRITE_RADIUES)];
    
    [self addChild:m_drawNode];
    
    //画点，随着半径的改变，圆会变大
    [m_drawNode drawDot:ccp(0, 0) radius:DRAWSPRITE_RADIUES color:m_color];
    
    //这个点是点击后选中状态的那个点
    m_selectNode = [CCDrawNode node];
    [m_drawNode addChild:m_selectNode];
    
    //计算出选中点的颜色，淡一点的颜色
    ccColor4F col = ccc4f(m_color.r, m_color.g, m_color.b, 255*0.75);
    
    //画出选中时的点
    [m_selectNode drawDot:ccp(0, 0) radius:DRAWSPRITE_RADIUES color:col];
    
    //初始状态是不可见的
    m_selectNode.visible = false;
//    [m_drawNode clear];
}

-(void)respawn{
    
    m_disappear = NO;
    [m_drawNode stopAllActions];
    [m_drawNode clear];
    [m_drawNode setScale:1.0];
    
    [m_selectNode clear];
    [m_selectNode setScale:1.0];
    
    [self calcColor];
    
    CGSize size = [CCDirector sharedDirector].winSize;
    CGFloat wd = [self anchorPoint].x * m_w + m_x * m_w +addWidth;
    
    [m_drawNode setPosition:ccp(wd, size.height)];
    
    [m_drawNode drawDot:self.position radius:DRAWSPRITE_RADIUES color:m_color];
    
    ccColor4F col = ccc4f(m_color.r, m_color.g, m_color.b, 255*0.75);
    
    [m_selectNode drawDot:ccp(0, 0) radius:DRAWSPRITE_RADIUES color:col];
    
    [self respawnDropdown];
}

-(void) spawnDropdown{
    m_dropCount = 0;
    
    [self stopAllActions];
    
    CGPoint pos = [self calcPos:m_x y:m_y];
    
    CCActionInterval * wait = [CCActionInterval actionWithDuration:m_y*SPAWN_DROPDOWN_TIME/5];
    
    CCMoveTo * moveto = [CCMoveTo actionWithDuration:SPAWN_DROPDOWN_TIME/2 position:pos];
    
    CCJumpTo * jump = [CCJumpTo actionWithDuration:SPAWN_JUMP_TIME position:pos height:30 jumps:1];
    
    CCCallBlockO * callB = [CCCallBlockO actionWithBlock:^(id object) {
        m_hasSelected = NO;
        self.visible = YES;
    } object:self];
    
    CCSequence * seq = [CCSequence actions:wait,moveto,jump,callB, nil];
    
    [m_drawNode runAction:seq];
}
-(void) respawnDropdown{
    m_dropCount = 0;
    
    [self stopAllActions];
    
    CGPoint pos = [self calcPos:m_x y:m_y];
    
//    CCActionInterval * wait = [CCActionInterval actionWithDuration:m_y*SPAWN_DROPDOWN_TIME/5];
    
    CCMoveTo * moveto = [CCMoveTo actionWithDuration:SPAWN_DROPDOWN_TIME/3 position:pos];
    
    CCJumpTo * jump = [CCJumpTo actionWithDuration:SPAWN_JUMP_TIME/3*2 position:pos height:20 jumps:1];
    
    CCCallBlockO * callB = [CCCallBlockO actionWithBlock:^(id object) {
        m_hasSelected = NO;
        self.visible = YES;
    } object:self];
    
    CCSequence * seq = [CCSequence actions:moveto,jump,callB, nil];
    
    [m_drawNode runAction:seq];
}

-(void)resetPropertyA:(NSInteger)x Y:(NSInteger)y{
    if (y <m_y) {
        m_dropCount ++;
    }
    m_x = x;
    m_y = y;
}

-(void)resetDropdown{
    
    m_hasSelected = YES;
    
    CGPoint pos = [self calcPos:m_x y:m_y];
    
    CCMoveTo *moveto = [CCMoveTo actionWithDuration:RESET_DROPDOWN_TIME position:pos];
    
    CCJumpTo * jump = [CCJumpTo actionWithDuration:RESET_JUMP_TIME/3
                                          position:pos height:15 jumps:1];
    
    CCCallBlockO * callB = [CCCallBlockO actionWithBlock:^(id object) {
        m_hasSelected = NO;
    } object:self];
    
    CCSequence * seq = [CCSequence actions:moveto, jump, callB, nil];
    
    [m_drawNode runAction:seq];
    m_dropCount = 0;
}

-(BOOL)positionInContent:(CGPoint)pos{
//    
//    CGFloat width = DRAWSPRITE_WIDTH;
//    CGFloat height = DRAWSPRITE_HEIGH;
    
    CGFloat orgx = m_drawNode.position.x - DRAWSPRITE_WIDTH;
    CGFloat orgy = m_drawNode.position.y - DRAWSPRITE_HEIGH;
    
    CGRect rect = CGRectMake(orgx, orgy, DRAWSPRITE_WIDTH*2, DRAWSPRITE_HEIGH*2);
    
    
    return  CGRectContainsPoint(rect, pos);//判断这个点是不是在一个rect的范围内，（这个点可能是一直移动的）
}

-(BOOL)selectedType{
    
    m_hasSelected = YES;
    
    [m_selectNode stopAllActions];
    [m_selectNode setScale:1.0];
    [m_selectNode setVisible:true];
    
    CCScaleBy * scaleBy = [CCScaleBy actionWithDuration:0.1 scale:2.0];
    CCCallBlock * block = [CCCallBlock actionWithBlock:^{
        [m_selectNode setVisible:false];
    }];
    
    CCSequence * seq = [CCSequence actions:scaleBy, [scaleBy reverse], block, nil];
    [seq setTag:caleActiontag];
    [m_selectNode runAction:seq];
    
    return YES;
}

-(void)disappear:(bool)callf{
    
    CCScaleBy * scaleBy = [CCScaleBy actionWithDuration:0.1 scale:1.5];
    CCScaleBy * scaleBy2 = [CCScaleBy actionWithDuration:0.2 scale:0];
    CCSequence * seq = NULL;
    
    if (callf) {
        CCCallBlockO * callfu  = [CCCallBlockO actionWithBlock:^(id object) {
            
            if (self.parent) {
                DataHandle * data = (DataHandle*)self.parent;
                [data disappearEnd];
            }
            
        } object:self];
        seq = [CCSequence actions:scaleBy,scaleBy2,callfu, nil];
    }else{
        seq = [CCSequence actions:scaleBy,scaleBy2, nil];
    }
    
    m_disappear = YES;
    
    [m_drawNode runAction:seq];
}

-(void) unselected{
    m_hasSelected = NO;
}

-(CGPoint)getDrawNodePosition{
    return m_drawNode.position;
}


-(void)KeepSelected{
    m_hasSelected = YES;
    
    [m_selectNode stopAllActions];
    
    [m_selectNode setVisible:true];
    
    CCScaleBy * scaleBy = [CCScaleBy actionWithDuration:0.1 scale:1.7];
    
    [m_selectNode runAction:scaleBy];
}

-(void)unKeepSelected{
    
    m_hasSelected = NO;
    [m_selectNode stopAllActions];
    
    CCScaleTo * scaleTo = [CCScaleTo actionWithDuration:0.1 scale:1.0];
    CCCallBlock * block = [CCCallBlock actionWithBlock:^{
        [m_selectNode setVisible:false];
    }];
    
    CCSequence * seq = [CCSequence actions:scaleTo, block, nil];
    [seq setTag:caleActiontag];
    [m_selectNode runAction:seq];
}

@end
