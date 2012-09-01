#import "UITableViewCell+NIB.h"

@implementation UITableViewCell (NIB)

+ (NSString *)cellID
{
    return NSStringFromClass(self);
}

+ (id)getFromTable:(UITableView *)table orLoadWithInitializer:(CellInitializer)init
{
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:self.cellID];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:self.cellID owner:nil options:nil];
        for (id obj in objects) {
            if ([obj isKindOfClass:self]) {
                cell = obj;
                if (init) {
                    init(cell);
                }
                return cell;
            }
        }
        return nil;
    }
    return cell;
}

@end
