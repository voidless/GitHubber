#import "RepositoryListController.h"
#import "Repository.h"
#import "RestKit.h"

@interface RepositoryListController () <RKObjectLoaderDelegate>
@end

@implementation RepositoryListController {
    NSArray *repositories;
}
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:@"/users/voidless/repos" delegate:self];
}

- (void)viewDidUnload
{
    tableView = nil;
    [super viewDidUnload];
}

#pragma mark RKObjectLoaderDelegate methods

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    NSLog(@"Loaded payload: %@", [response bodyAsString]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    NSLog(@"Loaded repos: %@", objects);
    repositories = objects;
    [tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    NSLog(@"Hit error: %@", error);
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

@end
