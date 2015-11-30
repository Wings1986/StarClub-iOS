/*
 
 Copyright (c) 2010, Mobisoft Infotech
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are
 permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of
 conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 Neither the name of Mobisoft Infotech nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
 OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 OF SUCH DAMAGE.
 
 */

#import "MIRadioButtonGroup.h"

@implementation MIRadioButtonGroup

@synthesize radioButtons;
@synthesize m_height;


- (id)initWithFrame:(CGRect)frame andOptions:(NSArray *)options{
	
	NSMutableArray *arrTemp =[[NSMutableArray alloc]init];
	self.radioButtons =arrTemp;
	[arrTemp release];
    
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		int framex =0;
		int framey = 0;

		for(int i=0; i < (int)[options count]; i++){
				
            int x = framex;
            int y = framey + 40 * i;
            
            UIButton *btTemp = [[UIButton alloc]initWithFrame:CGRectMake(x, y, 25, 25)];
            [btTemp addTarget:self action:@selector(radioButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btTemp setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
            btTemp.tag = i;

            UILabel * lbTemp = [[UILabel alloc] initWithFrame:CGRectMake(x + 35, y+12-25-20, 250, 90)];
            lbTemp.numberOfLines = 10;
            lbTemp.font = [UIFont fontWithName:FONT_NAME size:FONT_QUIZ_QUESTION];
            NSString * sTitle = [[options objectAtIndex:i] objectForKey:@"name"];
            lbTemp.textAlignment = NSTextAlignmentLeft;
            lbTemp.text = sTitle;
            
            [self.radioButtons addObject:btTemp];
            
            self.m_height = lbTemp.frame.origin.y + lbTemp.frame.size.height;
            
            
            [self addSubview:btTemp];
            [self addSubview:lbTemp];
            
            [btTemp release];
            [lbTemp release];
            
		}
        
		
	}
    return self;
}

- (void)dealloc {
	[radioButtons release];
    [super dealloc];
}

-(void) radioButtonClicked:(UIButton *) sender{
	for(int i=0;i<(int)[self.radioButtons count];i++){
		[[self.radioButtons objectAtIndex:i] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
	
	}
	[sender setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];

    int index = (int)sender.tag;
    [self.delegate setSelectedButton:index : self];
}

-(void) removeButtonAtIndex:(int)index{
	[[self.radioButtons objectAtIndex:index] removeFromSuperview];

}

-(void) setSelected:(int) index{
	for(int i=0;i<(int)[self.radioButtons count];i++){
		[[self.radioButtons objectAtIndex:i] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
		
	}
	[[self.radioButtons objectAtIndex:index] setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
}

-(void)clearAll{
	for(int i=0;i<(int)[self.radioButtons count];i++){
		[[self.radioButtons objectAtIndex:i] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
		
	}
}

@end
