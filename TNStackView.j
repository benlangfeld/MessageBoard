/*  
 * TNMessageView.j
 *    
 * Copyright (C) 2010 Antoine Mercadal <antoine.mercadal@inframonde.eu>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>


@implementation TNStackView: CPView
{
    CPArray     _dataSource     @accessors(property=dataSource);
    int         _padding        @accessors(property=padding);
    BOOL        _reversed       @accessors(getter=isReversed, setter=setReversed:);
    CPArray     _stackedViews;
    
}

- (id)initWithFrame:(CPRect)aFrame
{
    if(self = [super initWithFrame:aFrame])
    {
        _dataSource     = [CPArray array];
        _stackedViews   = [CPArray array];
        _padding        = 0;
        _reversed       = NO;
    }
    
    return self;
}

- (CPRect)_nextPosition
{
    var lastStackedView = [_stackedViews lastObject];
    var position;
    
    if (lastStackedView)
    {
        position = [lastStackedView frame];
        position.origin.y = position.origin.y + position.size.height + _padding;
        position.origin.x = _padding;
    }
    else
    {
        position = CGRectMake(_padding, _padding, [self bounds].size.width - (_padding * 2), 0);
    }
    
    return position
}


- (void)reload
{
    var frame = [self frame];
    
    frame.size.height = 0;
    [self setFrame:frame];
    
    for (var i = 0; i < [_dataSource count]; i++)
    {
        var view = [_dataSource objectAtIndex:i];
        
        if ([view superview])
            [view removeFromSuperview];
    }
    
    [_stackedViews removeAllObjects];
    [self layout];
}


- (void)layout
{
    var stackViewFrame  = [self frame];
    var workingArray    = _reversed ? [_dataSource copy].reverse() : _dataSource;
    
    stackViewFrame.size.height = 0;
    
    
    for(var i = 0; i < [workingArray count]; i++)
    {
        var currentView     = [workingArray objectAtIndex:i];
        var position        = [self _nextPosition];
        
        position.size.height = [currentView frameSize].height;
        [currentView setAutoresizingMask:CPViewWidthSizable];
        [currentView setFrame:position];
        
        if ([currentView respondsToSelector:@selector(layout)])
        {
            [currentView layout];
        }
            
        
        [self addSubview:currentView];
        [_stackedViews addObject:currentView];
        
        stackViewFrame.size.height += [currentView frame].size.height + _padding;
    }
    
    stackViewFrame.size.height += _padding;
    [self setFrame:stackViewFrame];
}

- (IBAction)removeAllViews:(id)aSender
{
    [_dataSource removeAllObjects];
    
    [self reload];
}

- (IBAction)reverse:(id)sender
{
    _reversed = !_reversed;
    
    [self reload];
}
@end
