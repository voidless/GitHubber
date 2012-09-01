#import "CommitListController.h"
#import "Repository.h"
#import "RestKit.h"
#import "CommitCell.h"
#import "UITableViewCell+NIB.h"
#import "ApiManager.h"
#import "Singletons.h"

@interface CommitListController () <UITableViewDataSource, UITableViewDelegate, RKObjectLoaderDelegate>
@end

@implementation CommitListController {
    Repository *repository;
    NSArray *commits;
    ApiManager *apiManager;
}
@synthesize tableView;

- (id)initWithRepository:(Repository *)aRepository
{
    if ((self = [self init])) {
        repository = aRepository;
    }
    return self;
}

- (id)init
{
    if ((self = [super init])) {
        apiManager = [ApiManager shared];
    }
    return self;
}

- (void)dealloc
{
    [apiManager cancelRequestsWithDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ commits", repository.name];

    [apiManager loadCommitsFromRepository:repository withDelegate:self];
}

- (void)viewDidUnload
{
    tableView = nil;
    [super viewDidUnload];
}

#pragma mark RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    commits = objects;
    [tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    NSLog(@"Error loading commits: %@", error);
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return [commits count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommitCell *cell = [CommitCell getFromTable:tv orLoadWithInitializer:nil];

    cell.commit = ([commits objectAtIndex:(NSUInteger) indexPath.row]);
    return cell;
}

@end
