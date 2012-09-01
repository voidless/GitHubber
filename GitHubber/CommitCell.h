#import <UIKit/UIKit.h>

@class Commit;

@interface CommitCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *hashLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) Commit *commit;

@end
