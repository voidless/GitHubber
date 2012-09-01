#import <Foundation/Foundation.h>

@interface KeychainItem : NSObject
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) id object;

- (id)initWithIdentifier:(NSString*)identifier;
- (id)initWithIdentifier:(NSString*)identifier account:(NSString*)account;

- (void)delete;

@end
