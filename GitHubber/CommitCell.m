#import "CommitCell.h"
#import "Commit.h"
#import "User.h"

@implementation CommitCell {
    NSDateFormatter *dateFormatter;
}
@synthesize messageLabel;
@synthesize authorLabel;
@synthesize dateLabel;
@synthesize commit;

- (void)awakeFromNib
{
    [super awakeFromNib];
    dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
}

- (void)setCommit:(Commit *)_commit
{
    commit = _commit;

    messageLabel.text = commit.message;
    authorLabel.text = commit.author.login;
    dateLabel.text = [dateFormatter stringFromDate:commit.date];
}

@end
