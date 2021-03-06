//
//  FeedViewController.m
//  instagramapp
//
//  Created by Laura Yao on 7/6/21.
//

#import "FeedViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "Post.h"
#import "igCell.h"
#import "DetailsViewController.h"
#import "CustomTapRecognizer.h"
#import "ProfileViewController.h"
#import "ComposeViewController.h"
#import "CommentViewController.h"

@interface FeedViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, igCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *postArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchPosts];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview: self.refreshControl atIndex:0];
    
    self.isMoreDataLoading = false;
    CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.tableView addSubview:self.loadingMoreView];
        
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"postHeader"];
    
    self.navigationItem.title = @"Instagram";
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"SavoyeLetPlain" size:40], NSForegroundColorAttributeName : [UIColor blackColor]};
}
- (void)fetchPosts{
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError *error) {
        if (posts != nil) {
            // do something with the array of object returned by the call
            self.postArray = posts;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
- (void) loadMoreData:(NSInteger)count{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    query.limit = count;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError *error) {
        if (posts != nil) {
            // do something with the array of object returned by the call
            self.postArray = posts;
            self.isMoreDataLoading = false;
            [self.loadingMoreView stopAnimating];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
- (IBAction)logoutAction:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error != nil){
            NSLog(@"Error");
        }
        else{
            SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            myDelegate.window.rootViewController = loginViewController;
        }
    }];
    
}
- (IBAction)composeAction:(id)sender {
    [self performSegueWithIdentifier:@"composeSegue" sender:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.postArray.count;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    igCell *cell = (igCell *) [tableView dequeueReusableCellWithIdentifier:@"igCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.post = (Post *)self.postArray[indexPath.section];
    [cell setPost:cell.post];
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *headerText = self.postArray[section][@"author"][@"username"];
    return [headerText lowercaseString];
}
- (void)handleTap:(UITapGestureRecognizer *)sender {
    CustomTapRecognizer *tap = (CustomTapRecognizer *)sender;
    [self performSegueWithIdentifier:@"postToProfSegue" sender:tap.author];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    UIImage *myImage = [UIImage imageNamed:@"blank-profile.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
    
    PFFileObject *userImageFile = self.postArray[section][@"author"][@"profilePic"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            imageView.image = [UIImage imageWithData:imageData];
        }
    }];
    
    UILabel *myLabel = [[UILabel alloc] init];
    [headerView addSubview:myLabel];
    [headerView addSubview:imageView];
    imageView.translatesAutoresizingMaskIntoConstraints = false;
    myLabel.translatesAutoresizingMaskIntoConstraints = false;
    
    [imageView.widthAnchor constraintEqualToConstant:25].active = YES;
    [imageView.heightAnchor constraintEqualToConstant:25].active = YES;
    [imageView.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:10].active = YES;
    [imageView.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-8].active = YES;
    
    [myLabel.leadingAnchor constraintEqualToAnchor:imageView.trailingAnchor constant:10].active = YES;
    [myLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-8].active = YES;
    [myLabel.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-8].active = YES;
    imageView.layer.cornerRadius = 25/2;
    imageView.layer.masksToBounds = YES;
    
    myLabel.font = [UIFont boldSystemFontOfSize:18];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    CustomTapRecognizer *recognizer = [[CustomTapRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    recognizer.author =self.postArray[section][@"author"];
    [headerView addGestureRecognizer:recognizer];
    [headerView setUserInteractionEnabled:YES];
    
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
     // Handle scroll behavior here
    if(!self.isMoreDataLoading){
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
               
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = true;
            CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
            self.loadingMoreView.frame = frame;
            [self.loadingMoreView startAnimating];
                   
            [self loadMoreData:[self.postArray count]+20];
        }

    }
}
- (void)igCell:(igCell *)igCell didComment:(Post *)post{
    // TODO: Perform segue to profile view controller
   [self performSegueWithIdentifier:@"commentSegue" sender:post];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"detailSegue"]){
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Post *poster = (Post *)self.postArray[indexPath.section];
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.post = poster;
    }
    else if([[segue identifier] isEqualToString:@"postToProfSegue"]){
        PFUser *ar = sender;
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.author = ar;
    }
    else if([[segue identifier] isEqualToString:@"commentSegue"]){
        Post *post = sender;
        CommentViewController *commentViewController = [segue destinationViewController];
        commentViewController.post = post;
    }
}


@end
