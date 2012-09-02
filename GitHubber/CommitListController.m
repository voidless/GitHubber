#import "CommitListController.h"
#import "Repository.h"
#import "RestKit.h"
#import "CommitCell.h"
#import "UITableViewCell+NIB.h"
#import "ApiManager.h"
#import "Singletons.h"
#import "LinkHTTPHeader.h"
#import "NSIndexPath+Array.h"

@interface CommitListController () <UITableViewDataSource, UITableViewDelegate, RKObjectLoaderDelegate>
@end

@implementation CommitListController {
    Repository *repository;
    NSMutableArray *commits;
    ApiManager *apiManager;
    LinkHTTPHeader *links;
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
        commits = [NSMutableArray new];
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
    links = [LinkHTTPHeader linkHTTPHeaderFromHeaders:objectLoader.response.allHeaderFields];

    NSArray *indexPaths = [NSIndexPath indexPathsWithRange:NSMakeRange(commits.count, objects.count) inSection:0];
    [commits addObjectsFromArray:objects];
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
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
    return commits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == commits.count - 1) {
        NSString *nextUrlString = [links linkForRel:@"next"];
        if (nextUrlString.length) {
            [apiManager loadObjectsAtURLString:nextUrlString withDelegate:self];
        }
    }

    CommitCell *cell = [CommitCell getFromTable:tv orLoadWithInitializer:nil];

    cell.commit = ([commits objectAtIndex:(NSUInteger) indexPath.row]);
    return cell;
}

@end
