#import "KeychainItem.h"

@implementation KeychainItem {
    NSMutableDictionary *search;
#if TARGET_IPHONE_SIMULATOR
    NSString *defKey;
#endif
}

- (id)initWithIdentifier:(NSString*)identifier
{
    return [self initWithIdentifier:identifier account:identifier];
}

- (id)initWithIdentifier:(NSString*)identifier account:(NSString*)account
{
    if ((self = [super init])) {
        search = [NSMutableDictionary new];
        [search setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [search setObject:identifier forKey:(__bridge id)kSecAttrService];
        [search setObject:account forKey:(__bridge id)kSecAttrAccount];
#if TARGET_IPHONE_SIMULATOR
        defKey = [NSString stringWithFormat:@"keychain.%@.%@", identifier, account];
#endif
    }
    return self;
}

- (NSMutableDictionary*)query
{
    return [search mutableCopy];
}

- (NSData*)data
{
#if TARGET_IPHONE_SIMULATOR
    return [[NSUserDefaults standardUserDefaults] objectForKey:defKey];
#else
    NSMutableDictionary *query = [search mutableCopy];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    CFTypeRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    NSData *data = CFBridgingRelease(result);
    return errSecSuccess == status ? data : nil;
#endif
}

- (void)setData:(NSData*)data
{
#if TARGET_IPHONE_SIMULATOR
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:data forKey:defKey];
    [defs synchronize];
#else
    BOOL exist = self.data != nil;
    OSStatus status = errSecSuccess;
    if (exist) {
        NSDictionary *update = [NSDictionary dictionaryWithObject:data forKey:(__bridge id)kSecValueData];
        status = SecItemUpdate((__bridge CFDictionaryRef)search, (__bridge CFDictionaryRef)update);
    } else {
        NSMutableDictionary *query = [search mutableCopy];
        [query setObject:data forKey:(__bridge id)kSecValueData];
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    }
#endif
}

- (id)object
{
    NSData *data = self.data;
    return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

- (void)setObject:(id)obj
{
    [self setData:[NSKeyedArchiver archivedDataWithRootObject:obj]];
}

- (void)delete
{
#if TARGET_IPHONE_SIMULATOR
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs removeObjectForKey:defKey];
    [defs synchronize];
#else
    SecItemDelete((__bridge CFDictionaryRef)self.query);
#endif
}

@end
