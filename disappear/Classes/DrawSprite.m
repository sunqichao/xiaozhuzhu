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

#pragma mark - 生成随机的color和随机的图片

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

#pragma mark - 初始化这个layer上的个个sprite，有正常点点，高亮的点点两种，并且初始化位置

-(void)spawnAtX:(NSInteger)x Y:(NSInteger)y Width:(CGFloat)w Height:(CGFloat)h{
    
    m_hasSelected = YES;
    m_disappear = NO;
    m_x = x;
    m_y = y;
    
    m_w = w*2;
    m_h = h*2;
    
    //创建出点的颜色
    [self calcColor];
    
    CGSize size = [CCDirector sharedDirector].winSize;
    
    //计算出每个点下落的的x坐标
    CGFloat wd = [self anchorPoint].x * m_w + x * m_w+addWidth;
    itemSrpint = [CCSprite spriteWithFile:self.sprintFile];
    
    //设置位置 size.height指的是点下落的那个高度  wd指的是下落时x轴的位置，如果wd设置为固定的值100则就会从一个点下落
    [itemSrpint setPosition:ccp(wd, size.height)];
    
    //设置矛点来确定位置
    [itemSrpint setAnchorPoint:CGPointMake(1.2, 1.2)];
    
    //设置原点物理大小
    [itemSrpint setContentSize:CGSizeMake(DRAWSPRITE_RADIUES, DRAWSPRITE_RADIUES)];
    [self addChild:itemSrpint];
    
    //这个点是点击后选中状态的那个点
    m_selectNode = [CCDrawNode node];
    
    //把高亮的图片添加上去
    [itemSrpint addChild:m_selectNode];
    
    //计算出选中点的颜色，淡一点的颜色
    ccColor4F col = ccc4f(m_color.r, m_color.g, m_color.b, 255*0.75);
    
    //画出选中时的点
    [m_selectNode drawDot:ccp(15, 15) radius:DRAWSPRITE_RADIUES color:col];
    
    //初始状态是不可见的
    m_selectNode.visible = false;

}

#pragma mark - 重新初始化点点的图片和高亮的图片

-(void)respawn{
    
    m_disappear = NO;
    [itemSrpint stopAllActions];
    [itemSrpint setScale:1.0];
    
    [m_selectNode clear];
    [m_selectNode setScale:1.0];
    
    [self calcColor];
    
    CGSize size = [CCDirector sharedDirector].winSize;
    CGFloat wd = [self anchorPoint].x * m_w + m_x * m_w +addWidth;
    
    
    [itemSrpint setPosition:ccp(wd, size.height)];
    
    CCTexture2D * texture =[[CCTextureCache sharedTextureCache] addImage:self.sprintFile];
    
    [itemSrpint setTexture:texture];

    ccColor4F col = ccc4f(m_color.r, m_color.g, m_color.b, 255*0.75);
    
    [m_selectNode drawDot:ccp(15, 15) radius:DRAWSPRITE_RADIUES color:col];
    
    [self respawnDropdown];
}

#pragma mark - 初始化下落的动画

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
    
    [itemSrpint runAction:seq];
    
    
    
}


-(void) respawnDropdown{
    m_dropCount = 0;
    
    [self stopAllActions];
    
    CGPoint pos = [self calcPos:m_x y:m_y];
    
    
    CCMoveTo * moveto = [CCMoveTo actionWithDuration:SPAWN_DROPDOWN_TIME/3 position:pos];
    
    CCJumpTo * jump = [CCJumpTo actionWithDuration:SPAWN_JUMP_TIME/3*2 position:pos height:20 jumps:1];
    
    CCCallBlockO * callB = [CCCallBlockO actionWithBlock:^(id object) {
        m_hasSelected = NO;
        self.visible = YES;
    } object:self];
    
    CCSequence * seq = [CCSequence actions:moveto,jump,callB, nil];
    
    [itemSrpint runAction:seq];
    
    
}

#pragma mark - 重设 x y 坐标

-(void)resetPropertyA:(NSInteger)x Y:(NSInteger)y{
    if (y <m_y) {
        m_dropCount ++;
    }
    m_x = x;
    m_y = y;
}

#pragma mark - 重设下落的动画

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
    
    
    
    [itemSrpint runAction:seq];
    m_dropCount = 0;
}

#pragma mark - 判断触摸是否在点的范围内

-(BOOL)positionInContent:(CGPoint)pos{
    //
    //    CGFloat width = DRAWSPRITE_WIDTH;
    //    CGFloat height = DRAWSPRITE_HEIGH;
    
    CGFloat orgx = itemSrpint.position.x - DRAWSPRITE_WIDTH;
    CGFloat orgy = itemSrpint.position.y - DRAWSPRITE_HEIGH;
    
    CGRect rect = CGRectMake(orgx, orgy, DRAWSPRITE_WIDTH*2, DRAWSPRITE_HEIGH*2);
    
    
    return  CGRectContainsPoint(rect, pos);//判断这个点是不是在一个rect的范围内，（这个点可能是一直移动的）
}


#pragma mark - 点击小点点后的高亮动画

-(BOOL)selectedType{
    
    m_hasSelected = YES;
    
    [m_selectNode stopAllActions];
    [m_selectNode setScale:1.0];
    [m_selectNode setVisible:true];
    
    //缩放的动画
    CCScaleBy * scaleBy = [CCScaleBy actionWithDuration:0.1 scale:2.0];
    CCCallBlock * block = [CCCallBlock actionWithBlock:^{
        [m_selectNode setVisible:false];
    }];
    
    CCSequence * seq = [CCSequence actions:scaleBy, [scaleBy reverse], block, nil];
    [seq setTag:caleActiontag];
    [m_selectNode runAction:seq];
    
    return YES;
}


#pragma mark - 相同颜色的点，消失后的动画，缩小到没有

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
    
    [itemSrpint runAction:seq];
}

#pragma mark - 状态改为没有选中的

-(void) unselected{
    m_hasSelected = NO;
}

#pragma mark - 获得点点在view上的位置

-(CGPoint)getDrawNodePosition{
    return itemSrpint.position;
}


#pragma mark - 让点点处于选中状态

-(void)KeepSelected{
    m_hasSelected = YES;
    
    [m_selectNode stopAllActions];
    
    [m_selectNode setVisible:true];
    
    CCScaleBy * scaleBy = [CCScaleBy actionWithDuration:0.1 scale:1.7];
    
    [m_selectNode runAction:scaleBy];
}

#pragma mark - 让点点恢复正常状态

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
