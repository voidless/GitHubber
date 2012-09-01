#import "RepositoryListController.h"
#import "Repository.h"
#import "RestKit.h"
#import "RepositoryController.h"

@interface RepositoryListController () <RKObjectLoaderDelegate, UITableViewDataSource, UITableViewDelegate>
@end

@implementation RepositoryListController {
    NSArray *repositories;
    RKObjectManager *objectManager;
}
@synthesize tableView;

- (id)init
{
    if ((self = [super init])) {
        objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

- (void)dealloc
{
    [objectManager.requestQueue cancelRequestsWithDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Repositories";

    [objectManager loadObjectsAtResourcePath:@"/user/repos" delegate:self];
}

- (void)viewDidUnload
{
    tableView = nil;
    [super viewDidUnload];
}

#pragma mark RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    repositories = objects;
    [tableView reloadData];
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
    return [repositories count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
