//
//  AudioTableViewCell.m
//  AVPlayerApp
//
//  Created by Daniel Cardona on 8/31/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "AudioTableViewCell.h"

@implementation AudioTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
