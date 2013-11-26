//
//  DotHudController.m
//  disappear
//
//  Created by CpyShine on 13-6-5.
//  Copyright 2013年 CpyShine. All rights reserved.
//

#import "DotHudController.h"

#import "DotPlayingScnen.h"

#import "DownStateLayer.h"
#import "UpStateLayer.h"
#import "PauseLayer.h"
#import "TopScoreLayer.h"

@implementation DotHudController


- (id)init
{
    self = [super init];
    if (self) {
        
        //底部放必杀得选项
        m_downStateLayer    = [DownStateLayer node];
        
        //顶部显示时间和分数得按钮
        m_upstateLayer      = [UpStateLayer node];
        
        //暂停得layer
        m_pauseLayer        = [PauseLayer node];
        
        //游戏时间到后跳转得界面，最高分，等级得界面
        m_topScoreLayer     = [TopScoreLayer node];
        
        
        [self addChild:m_downStateLayer z:2];
        [self addChild:m_upstateLayer z:2];
        [self addChild:m_pauseLayer z:1];
        [self addChild:m_topScoreLayer];
    }
    return self;
}

-(void)onEnter{
    [super onEnter];
    
    [m_upstateLayer startAnimationDisplay];
    [m_downStateLayer startAnimationDisplay];
}

-(void)startGame{
    if (self.parent) {
        DotPlayingScnen * dps = (DotPlayingScnen*)self.parent;
        [dps startDotGame];
    }
}

-(void)gamePause{
    if (m_pause) {
        if (self.parent) {
            [m_pauseLayer setVisible:false];
            DotPlayingScnen * playing = (DotPlayingScnen*)self.parent;
            [playing resumeGame];
            m_pause = false;
        }
    }else{
        if (self.parent) {
            [m_pauseLayer startAnimationDiaplay];
            DotPlayingScnen * playing = (DotPlayingScnen*)self.parent;
            [playing pauseGame];
            m_pause = true;
        }
    }
}

-(void) currentGameOver:(NSInteger)score{
    
    
    [m_downStateLayer setVisible:false];;
    [m_upstateLayer setVisible:false];
    [m_pauseLayer setVisible:false];
    [m_topScoreLayer startAnimationDisplay:score];
}


-(void)resetTimeString:(NSString *)string{
    [m_upstateLayer resetTimeString:string];
}
-(void)resetScoreString:(NSString *)string{
    [m_upstateLayer resetScoreString:string];
}


-(void)playerUseSkill:(PLAYERTOOLTYPE)skillTpye{
    if (self.parent) {
        DotPlayingScnen * playing = (DotPlayingScnen*)self.parent;
        if (playing) {
            [playing playerUsedToolDisappear:skillTpye];
        }
    }
}

@end
