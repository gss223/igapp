//
//  Post.m
//  instagramapp
//
//  Created by Laura Yao on 7/6/21.
//

#import "Post.h"
#import <Parse/Parse.h>


@implementation Post
@dynamic objectId;
@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic caption;
@dynamic image;
@dynamic likeCount;
@dynamic commentCount;
@dynamic createdAt;
@dynamic likes;



+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postUserImage: ( UIImage * _Nullable )image withCaption: ( NSString * _Nullable )caption withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Post *newPost = [Post new];
    
    newPost.image = [self getPFFileFromImage:image];
    
    newPost.author = [PFUser currentUser];
    newPost.caption = caption;
    newPost.likeCount = @(0);
    newPost.commentCount = @(0);
    newPost.createdAt = [NSDate date];
    newPost.likes =[[NSMutableArray alloc] init];
    
    [newPost saveInBackgroundWithBlock: completion];
    
  
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
 
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}


@end
