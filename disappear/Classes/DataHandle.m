//
//  DataHandle.m
//  disappear
//
//  Created by CpyShine on 13-5-29.
//  Copyright 2013年 CpyShine. All rights reserved.
//

#import "DataHandle.h"

#include "SimpleAudioEngine.h"

#import "DrawSprite.h"
#import "DotPlayingScnen.h"

@implementation DataHandle


static inline int calcIndex(int x,int y){
    return TOTALX * y + x;
}

- (id)init
{
    //把最后一个参数改为0就设置背景为透明了
    self = [super initWithColor:ccc4(255, 255, 255, 0)];//WithColor:ccc4(230, 230, 230, 255)
    
    if (self) {
        
        m_drawSpriteArray = [[NSMutableArray alloc]init];
        
        for (int y = 0; y<TOTALY; y++) {
            for (int x = 0; x<TOTALX; x++) {
                
                DrawSprite * drawS = [DrawSprite node];
                
                [drawS spawnAtX:x Y:y Width:DRAWSPRITE_WIDTH Height:DRAWSPRITE_HEIGH];
                
                [m_drawSpriteArray addObject:drawS];
                
                [self addChild:drawS z:1];
            }
        }
        m_stackArray = [[NSMutableArray alloc]init];
        
        
    }
    self.visible = false;
    [self loadEffectSounds];
    return self;
}

-(void) loadEffectSounds{
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/1.aif"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/2.aif"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/3.aif"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/4.aif"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/5.aif"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/6.aif"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/7.aif"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/8.aif"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/9.aif"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/10.aif"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/11.aif"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/12.aif"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Sounds/13.aif"];
}

//-(void)onEnter{
//    [super onEnter];
//    
//}

-(DrawSprite *)getCurrentSelectSprite:(CGPoint)pos {
    if (m_drawSpriteArray) {
        
        for (DrawSprite * node in m_drawSpriteArray) {
            
            if (node && [node positionInContent:pos]) {
                return node;
            }
        }
    }
    
    return NULL;
}

#pragma mark - 开始触摸

-(BOOL) touchBegine:(CGPoint)local{
    
    if (m_toolsDisappear) {
        
        [self toolDisappearSelected:local];
        
        return false;
    }
    
    m_movePos = local;
    m_objectHasContina = NO;
    m_removeAllSameColor = NO;
    
    if (m_stackArray.count !=0) {
        for (DrawSprite * node in m_stackArray) {
            [node unselected];
        }
        [m_stackArray removeAllObjects];
    }
    
    DrawSprite * ds = [self getCurrentSelectSprite:local];
    
    if (ds && [ds selectedType]) {
        
        [m_stackArray addObject:ds];
        [self playingSound:m_stackArray.count];
        m_currentDrawColor = ds.m_color;
        m_drawLine = YES;
        return YES;
    }
    return NO;
}

#pragma mark - 开始滑动

-(void) touchMove:(CGPoint)local{
    
    m_movePos = local;
    
    DrawSprite * ds = [self getCurrentSelectSprite:local];
    
    if (ds && ccc4FEqual(m_currentDrawColor, ds.m_color)) {
        
        if (ds == [m_stackArray lastObject]) {
            return;
        }
        if (m_stackArray.count >=2 &&
            ds == [m_stackArray objectAtIndex:(m_stackArray.count-2)]) {//退一格
            
            DrawSprite * tds = [m_stackArray lastObject];
            [tds unselected];
            if (m_objectHasContina) {
                m_removeAllSameColor = NO;
                m_objectHasContina = NO;
            }
            
            [m_stackArray removeLastObject];
            [ds selectedType];
            [self playingSound:m_stackArray.count];//play sounds
            return;
        }
        
        if (!m_objectHasContina && [m_stackArray containsObject:ds]) {
            
            DrawSprite * tds = [m_stackArray lastObject];
            
            NSInteger absValue = abs(ds.m_x - tds.m_x) + abs(ds.m_y - tds.m_y);
            [ds unselected];
            if (absValue == 1 && [ds selectedType]) {
                
                m_objectHasContina = YES;
                m_removeAllSameColor = YES;
                
                [m_stackArray addObject:ds];
                [self playingSound:m_stackArray.count];//play sounds
            }
        }
        
        if (m_objectHasContina && [m_stackArray containsObject:ds]) {
            return;
        }
        
        m_objectHasContina = NO;
        DrawSprite * tds = [m_stackArray lastObject];
        
        NSInteger absValue = abs(ds.m_x - tds.m_x) + abs(ds.m_y - tds.m_y);
        
        if (absValue == 1 && [ds selectedType]) {
            [m_stackArray addObject:ds];//play sounds
            [self playingSound:m_stackArray.count];
        }
    }
}

#pragma mark - 消除得分的点点，并加分

-(void)touchEnd{
    m_drawLine = NO;
    
    NSInteger disappearCount = 0;
    
    if (m_stackArray.count>=2) {
        if (m_removeAllSameColor) {
            
            [self disappearAllSameColorDotsWithSelected];
            
        }else{
            for (int i=0; i<m_stackArray.count; i++) {
                DrawSprite * node = [m_stackArray objectAtIndex:i];
                if (node) {
                    if (i == m_stackArray.count-1) {
                        [node disappear:YES];
                    }
                    [node disappear:NO];
                    disappearCount ++;
                }
            }
        }
    }else{
        for (DrawSprite * node in m_stackArray) {
            [node unselected];
        }
    }
    [m_stackArray removeAllObjects];
    
    if (self.parent) {
        
        //加分数
        [self.parent playingScoreAdd:disappearCount];
        
//        DotPlayingScnen * playing = (DotPlayingScnen*)self.parent;
//        
//        if (playing) {
//            [playing playingScoreAdd:disappearCount];
//        }
    }
}

-(NSInteger) disappearAllSameColorDotsWithSelected{
    NSInteger count = 0;
    BOOL dis = YES;
    for (int i=0; i<m_drawSpriteArray.count; i++) {
        DrawSprite * node = [m_drawSpriteArray objectAtIndex:i];
        if (node && ccc4FEqual(m_currentDrawColor, node.m_color)) {
            if (dis) {
                [node disappear:YES];
                dis = NO;
            }
            [node disappear:NO];
            count ++;
        }
    }
    return count;
}

#pragma mark - 画线的方法 （这个方法会一直调用）

-(void)draw{
    [super draw];
    
    if (m_drawLine && m_canPlaying) {
        
        glLineWidth(10);
    
        ccColor4B c4b = ccc4BFromccc4F(m_currentDrawColor);
        ccDrawColor4B(c4b.r, c4b.g, c4b.b, c4b.a);
        
        
        if ([m_stackArray count]>=2) {
            DrawSprite * ds = [m_stackArray objectAtIndex:0];
            CGPoint pos = [ds getDrawNodePosition];
            
            //这个循环是给所有连起来的点画线（都是固定的）
            for (int c=1; c<m_stackArray.count; c++) {
                ds  = [m_stackArray objectAtIndex:c];
                CGPoint pos1 = [ds getDrawNodePosition];
                ccDrawLine(pos, pos1);
                pos = pos1;
            }
        }
        DrawSprite * ds = [m_stackArray lastObject];
        CGPoint pos = [ds getDrawNodePosition];
        
        //这个画线是把最后一个固定的点和手指移动的位置相连起来 （根据手指移动到哪里就连接到哪里）
        ccDrawLine(pos, m_movePos);
    }
}

#pragma mark - 圆点点消除后

-(void)disappearEnd{
    
    NSMutableArray * dropArray = [NSMutableArray array];
    
    for (int i = 0; i< m_drawSpriteArray.count; i++) {
        DrawSprite * ds = (DrawSprite*)[m_drawSpriteArray objectAtIndex:i];
        
        [self calcDropDown:ds ResultArray:dropArray];
    }
    
    for (int i = 0; i<dropArray.count; i++) {
        
        DrawSprite * ds = (DrawSprite*)[dropArray objectAtIndex:i];
        
        [ds resetDropdown];
    }
    
    for (int i = 0; i< m_drawSpriteArray.count; i++) {
        
        DrawSprite * ds = (DrawSprite*)[m_drawSpriteArray objectAtIndex:i];
        
        if (ds.m_disappear) {
            [ds respawn];
        }
    }
}

#pragma mark - 下落点 当有点点成功消除后会产生新得点点来填充

-(void) calcDropDown:(DrawSprite*) drawSprite ResultArray:(NSMutableArray *) resultArray{
    
    if (!drawSprite) {
        return;
    }
    
    /*
     感觉是点都在上面，连接相同颜色得点消除后，并不是删除，而是做一个缩放得动画，然后再让这几个点从天上再掉下来一次，前提是先把之前得空缺补上，然后再计算新得位置
     */
    
    while (true) {
        NSInteger x = drawSprite.m_x;
        NSInteger y = drawSprite.m_y;
        
        NSInteger index = y*TOTALY + x;
        NSInteger nIndex = (y-1) * TOTALY +x;
        
        if (nIndex<0) {
            break;
        }
        
        DrawSprite * nDS = (DrawSprite *)[m_drawSpriteArray objectAtIndex:nIndex];
        if (nDS && nDS.m_disappear) {
            NSInteger nX = nDS.m_x;
            NSInteger nY = nDS.m_y;
            
            [nDS resetPropertyA:x Y:y];
            [drawSprite resetPropertyA:nX Y:nY];
            
            [m_drawSpriteArray exchangeObjectAtIndex:index withObjectAtIndex:nIndex];
            
            if (![resultArray containsObject:drawSprite] && !drawSprite.m_disappear) {
                [resultArray addObject:drawSprite];
            }
        }
        if(nDS && !nDS.m_disappear){
            break;
        }
    }
}

#pragma mark - 必杀的执行方法，会消除所有选中的颜色的点

-(void) toolDisappearSelected:(CGPoint) local{
    
    DrawSprite * ds = [self getCurrentSelectSprite:local];
    
    int count = 0;
    
    if (ds) {
        
        [self cancelAllDrawNodeBeSelected];
        
        if (m_toolsDisappearType) {
            
            m_currentDrawColor = ds.m_color;
            count = [self disappearAllSameColorDotsWithSelected];
        }else{
            [ds disappear:YES];
            count = 1;
        }
        m_toolsDisappear = NO;
        
        
        
        if (self.parent) {
            
            DotPlayingScnen * playing = (DotPlayingScnen*)self.parent;
            
            if (playing) {
                [playing playingScoreAdd:count];
            }
        }
    }
    
}

#pragma mark - 大招，放必杀

-(BOOL)allDrawNodeBeSelected:(BOOL)disappearType{
    
    if (m_toolsDisappear) {
        return NO;
    }
    
    m_toolsDisappearType = disappearType;
    m_toolsDisappear = YES;
    
    for (int i=0; i< m_drawSpriteArray.count; i++) {
        
        DrawSprite *ds = (DrawSprite *)[m_drawSpriteArray objectAtIndex:i];
        if (ds) {
            [ds KeepSelected];
        }
    }
    
    return YES;
}

#pragma mark - 取消所有点的选中状态

-(void) cancelAllDrawNodeBeSelected{
    
    for (int i=0; i< m_drawSpriteArray.count; i++) {
        
        DrawSprite *ds = (DrawSprite *)[m_drawSpriteArray objectAtIndex:i];
        if (ds) {
            [ds unKeepSelected];
        }
    }
}

#pragma mark - datahandle  设置点点落下来的动画

-(void)startAnimtionDisplay{
    self.visible = true;
    if (m_drawSpriteArray) {
        
        for (DrawSprite * node in m_drawSpriteArray) {
            
            if (node) {
                [node spawnDropdown];
            }
        }
    }
}

#pragma mark - datahandle  设置点点落下来的动画f

-(void)startPlaying{
    
    m_toolsDisappear = false;
    m_canPlaying = YES;
    
    //kCCTouchesOneByOne触控方式
    [self setTouchMode:kCCTouchesOneByOne];
    
    //设置为可以触摸
    [self setTouchEnabled:YES];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if (!m_canPlaying) {
        return NO;
    }
    
    CGPoint touchLocation = [touch locationInView: [touch view]];
    
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    
    CGPoint local = [self convertToNodeSpace:touchLocation];
    
    
    return [self touchBegine:local];
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    
    
    if (!m_canPlaying) {
        return ;
    }
    
    CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    
    CGPoint local = [self convertToNodeSpace:touchLocation];
    
    
    [self touchMove:local];
}


-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    [self touchEnd];
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    [self touchEnd];
}

-(void)moveOut{
    m_canPlaying = false;
    [self setVisible:false];
}

-(void)moveIn{
    m_canPlaying = true;
    [self setVisible:true];
}


#pragma mark - 根据点数量来播放声音

-(void) playingSound:(NSInteger) count{
    
    if (count>13) {
        count = 13;
    }
    
    NSString * soundName = [NSString stringWithFormat:@"Sounds/%d.aif",count];
    
    [[SimpleAudioEngine sharedEngine] playEffect:soundName];
    
}



- (void)dealloc
{
    [m_stackArray removeLastObject]; [m_stackArray release];
    [m_drawSpriteArray removeLastObject]; [m_drawSpriteArray release];
    
    [super dealloc];
}



@end
