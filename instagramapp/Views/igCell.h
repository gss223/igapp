//
//  igCell.h
//  instagramapp
//
//  Created by Laura Yao on 7/6/21.
//

#import <UIKit/UIKit.h>
#import "Post.h"
//#import "Comment.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN
@protocol igCellDelegate;
@interface igCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *postCaption;
@property (weak, nonatomic) IBOutlet PFImageView *postImageViw;
@property (weak, nonatomic) IBOutlet UILabel *postTime;
@property (nonatomic, strong) Post *post;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) id<igCellDelegate> delegate;

@end

@protocol igCellDelegate
- (void)igCell:(igCell *)igCell didComment:(Post *)post;
@end

NS_ASSUME_NONNULL_END
