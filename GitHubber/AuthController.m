#import "AuthController.h"
#import "RepositoryListController.h"
#import <RestKit/RestKit.h>

@interface AuthController ()
@end

@implementation AuthController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark Actions

- (IBAction)signIn:(UIButton *)sender
{
    RepositoryListController *repositoryListController = [RepositoryListController new];
    [self.navigationController pushViewController:repositoryListController animated:YES];
}

@end
