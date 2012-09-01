#import "AuthController.h"
#import "RepositoryListController.h"
#import "Authorization.h"
#import "KeychainItem.h"
#import <RestKit/RestKit.h>

@interface AuthController () <UITextFieldDelegate, RKObjectLoaderDelegate>
@end

@implementation AuthController {
    Authorization *authorization;
    RKObjectManager *objectManager;
    CGFloat keyboardHeight;
    KeychainItem *keychainItem;
}
@synthesize scrollView;
@synthesize authView;
@synthesize authFormView;
@synthesize loggedView;
@synthesize loadingView;
@synthesize loginTextField;
@synthesize passwordTextField;
@synthesize loginButton;

- (id)initWithKeychainItem:(KeychainItem *)keychain
{
    if ((self = [self init])) {
        keychainItem = keychain;
        id auth = keychainItem.object;
        if ([auth isKindOfClass:[Authorization class]]) {
            [self setupManagerWithAuth:auth];
        }
    }
    return self;
}

- (id)init
{
    if ((self = [super init])) {
        objectManager = [RKObjectManager sharedManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.title = @"GitHubber";

    if (authorization) {
        [self loggedIn];
    } else {
        [self loggedOut];
    }
}

- (void)viewDidUnload
{
    [self setLoginTextField:nil];
    [self setPasswordTextField:nil];
    [self setLoginButton:nil];
    [self setScrollView:nil];
    [self setAuthView:nil];
    [self setAuthFormView:nil];
    [self setLoggedView:nil];
    [self setLoadingView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterKeyboardNotifications];
}

#pragma mark Private

- (void)setupManagerWithAuth:(Authorization *)auth
{
    authorization = auth;

    objectManager.client.authenticationType = RKRequestAuthenticationTypeOAuth2;
    objectManager.client.OAuth2AccessToken = authorization.token;
}

- (void)showRepositoryList
{
    RepositoryListController *ctrl = [RepositoryListController new];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)loggedIn
{
    [authView removeFromSuperview];
    loadingView.hidden = YES;

    [scrollView addSubview:loggedView];
    CGRect rect = self.scrollView.bounds;
    loggedView.frame = rect;
    scrollView.contentSize = rect.size;
    [self showRepositoryList];
}

- (void)loggedOut
{
    [loggedView removeFromSuperview];
    loadingView.hidden = YES;

    [scrollView addSubview:authView];
    CGRect rect = self.scrollView.bounds;
    loggedView.frame = rect;
    scrollView.contentSize = rect.size;
}

- (void)loading
{
    [authView removeFromSuperview];
    [loggedView removeFromSuperview];
    loadingView.hidden = NO;
}

- (void)checkInput
{
    loginButton.enabled = loginTextField.text.length && passwordTextField.text.length;
}

#pragma mark Actions

- (IBAction)showRepositories:(UIButton *)sender
{
    [self showRepositoryList];
}

- (IBAction)logIn:(UIButton *)sender
{
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    objectManager.client.username = loginTextField.text;
    objectManager.client.password = passwordTextField.text;

    Authorization *auth = [Authorization new];
    auth.note = @"GitHubber";
    auth.scopes = [NSArray arrayWithObjects:@"repo", nil];
    [objectManager postObject:auth delegate:self];
    [self loading];
}

- (IBAction)logOut:(UIButton *)sender
{
    authorization = nil;
    [keychainItem delete];
    [self loggedOut];
}

- (IBAction)resignEditing:(id)sender
{
    [authView endEditing:NO];
}

#pragma mark RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(Authorization *)auth
{
    keychainItem.object = auth;
    [self setupManagerWithAuth:auth];
    [self loggedIn];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    NSLog(@"Hit error: %@", error);
    [self loggedOut];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    dispatch_async(dispatch_get_current_queue(), ^{
        [self.scrollView scrollRectToVisible:authFormView.frame animated:YES];
    });
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.text = newText;
    [self checkInput];
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Keyboard

- (void)registerKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGRect keyboardFrameEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardRect = [self.view convertRect:keyboardFrameEnd fromView:nil];
    CGFloat height = self.view.bounds.size.height - keyboardRect.origin.y;
    keyboardHeight = height;

    UIEdgeInsets i = self.scrollView.contentInset;
    i.bottom += keyboardHeight;
    [UIView animateWithDuration:duration animations:^{
        self.scrollView.contentInset = i;
        self.scrollView.scrollIndicatorInsets = i;
    }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];

    UIEdgeInsets i = self.scrollView.contentInset;
    i.bottom -= keyboardHeight;
    [UIView animateWithDuration:duration animations:^{
        self.scrollView.contentInset = i;
        self.scrollView.scrollIndicatorInsets = i;
    }];
}

@end
