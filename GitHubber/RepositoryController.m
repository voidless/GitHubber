#import "RepositoryController.h"
#import "Repository.h"
#import "User.h"
#import "Singletons.h"
#import "Gravatar.h"
#import "CommitListController.h"

#define DESC_LABEL_BOTTOM_MARGIN 10

@implementation RepositoryController
@synthesize repository;
@synthesize scrollView;
@synthesize contentView;
@synthesize activityIndicatorView;
@synthesize nameLabel;
@synthesize descLabel;
@synthesize forksLabel;
@synthesize watchersLabel;
@synthesize imageView;
@synthesize ownerLabel;

- (id)initWithRepository:(Repository *)repo
{
    if ((self = [super init])) {
        self.repository = repo;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = repository.name;

    nameLabel.text = repository.name;
    descLabel.text = repository.desc;
    forksLabel.text = [NSString stringWithFormat:@"%d", [repository.forks integerValue]];
    watchersLabel.text = [NSString stringWithFormat:@"%d", [repository.watchers integerValue]];
    ownerLabel.text = repository.owner.login;

    NSUInteger imageSize = (NSUInteger) ([UIScreen mainScreen].scale * imageView.bounds.size.width);
    [self loadOwnerAvatarWithURL:[repository.owner.gravatar imageURLWithSize:imageSize]];

    [descLabel sizeToFit];
    CGRect frame = contentView.frame;
    CGFloat height = descLabel.frame.origin.y + descLabel.frame.size.height + DESC_LABEL_BOTTOM_MARGIN;
    frame.size.height = MAX(height, frame.size.height);
    contentView.frame = frame;

    [scrollView addSubview:contentView];
    scrollView.contentSize = frame.size;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setContentView:nil];
    [self setImageView:nil];
    [self setOwnerLabel:nil];
    [self setNameLabel:nil];
    [self setForksLabel:nil];
    [self setWatchersLabel:nil];
    [self setDescLabel:nil];
    [self setActivityIndicatorView:nil];
    [super viewDidUnload];
}

#pragma mark Actions

- (IBAction)showCommits:(UIButton *)sender
{
    CommitListController *ctrl = [[CommitListController alloc] initWithRepository:repository];
    [self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark Private

- (void)loadOwnerAvatarWithURL:(NSURL *)imageUrl
{
    UIImage *cachedImage = [[ImageCache shared] imageWithURL:imageUrl
            callback:[^(ImageCache *cache, NSURL *url, UIImage *image) {
                [activityIndicatorView stopAnimating];
                [activityIndicatorView removeFromSuperview];
                imageView.image = image;
            } copy] errback:[^(ImageCache *cache, NSURL *url, NSError *error) {
                [activityIndicatorView stopAnimating];
                [activityIndicatorView removeFromSuperview];
            } copy]];
    if (cachedImage) {
        imageView.image = cachedImage;
    } else {
        [imageView addSubview:activityIndicatorView];
        activityIndicatorView.center = CGPointMake(imageView.bounds.size.width / 2, imageView.bounds.size.height / 2);
        [activityIndicatorView startAnimating];
    }
}

@end
