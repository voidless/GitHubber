#import "RepositoryListController.h"
#import "Repository.h"
#import "RestKit.h"
#import "RepositoryController.h"
#import "ApiManager.h"
#import "Singletons.h"
#import "LinkHTTPHeader.h"
#import "NSIndexPath+Array.h"

@interface RepositoryListController () <RKObjectLoaderDelegate, UITableViewDataSource, UITableViewDelegate>
@end

@implementation RepositoryListController {
    NSMutableArray *repositories;
    ApiManager *apiManager;
    LinkHTTPHeader *links;
}
@synthesize tableView;

- (id)init
{
    if ((self = [super init])) {
        apiManager = [ApiManager shared];
        repositories = [NSMutableArray new];
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
    self.title = @"Repositories";
    [apiManager loadRepositoriesWithDelegate:self];
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

    NSArray *indexPaths = [NSIndexPath indexPathsWithRange:NSMakeRange(repositories.count, objects.count) inSection:0];
    [repositories addObjectsFromArray:objects];
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    NSLog(@"Error loading repos: %@", error);
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return repositories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == repositories.count - 1) {
        NSString *nextUrlString = [links linkForRel:@"next"];
        if (nextUrlString.length) {
            [apiManager loadObjectsAtURLString:nextUrlString withDelegate:self];
        }
    }

    NSString *reuseIdentifier = @"Repository Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }

    Repository *repository = [repositories objectAtIndex:(NSUInteger) indexPath.row];
    cell.textLabel.text = repository.name;
    cell.detailTextLabel.text = repository.desc;
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Repository *repo = [repositories objectAtIndex:(NSUInteger) indexPath.row];
    RepositoryController *ctrl = [[RepositoryController alloc] initWithRepository:repo];
    [self.navigationController pushViewController:ctrl animated:YES];
}

@end
