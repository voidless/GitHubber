#import <Foundation/Foundation.h>

typedef void (^CellInitializer)(id cell);

@interface UITableViewCell (NIB)

+ (NSString*)cellID;

+ (id)getFromTable:(UITableView*)table orLoadWithInitializer:(CellInitializer)init;

@end
