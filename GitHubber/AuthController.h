#import <UIKit/UIKit.h>

@class Authorization;
@class KeychainItem;

@interface AuthController : UIViewController

- (id)initWithKeychainItem:(KeychainItem *)keychain;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *authView;
@property (strong, nonatomic) IBOutlet UIView *authFormView;
@property (strong, nonatomic) IBOutlet UIView *loggedView;
@property (strong, nonatomic) IBOutlet UIView *loadingView;

@property (strong, nonatomic) IBOutlet UITextField *loginTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)showRepositories:(UIButton *)sender;
- (IBAction)logIn:(UIButton *)sender;
- (IBAction)logOut:(UIButton *)sender;
- (IBAction)resignEditing:(id)sender;

@end
