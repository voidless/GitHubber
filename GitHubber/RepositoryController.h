#import <UIKit/UIKit.h>

@class Repository;

@interface RepositoryController : UIViewController

- (id)initWithRepository:(Repository *)repository;

@property (strong, nonatomic) Repository *repository;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UILabel *forksLabel;
@property (strong, nonatomic) IBOutlet UILabel *watchersLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *ownerLabel;

- (IBAction)showCommits:(UIButton *)sender;

@end
