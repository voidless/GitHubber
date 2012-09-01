#import <UIKit/UIKit.h>

@class Repository;

@interface CommitListController : UIViewController

- (id)initWithRepository:(Repository *)aRepository;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
