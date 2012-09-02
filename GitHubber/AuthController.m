#import "AuthController.h"
#import "RepositoryListController.h"
#import "Authorization.h"
#import "KeychainItem.h"
#import "RestKit.h"
#import "ApiManager.h"
#import "Singletons.h"

@interface AuthController () <UITextFieldDelegate, RKObjectLoaderDelegate>
@end

@implementation AuthController {
    Authorization *authorization;
    ApiManager *apiManager;
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
        apiManager = [ApiManager shared];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestDidLoadResponse:) name:RKRequestDidLoadResponseNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [apiManager cancelRequestsWithDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RKRequestDidLoadResponseNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

#pragma mark Actions

- (IBAction)showRepositories:(UIButton *)sender
{
    [self showRepositoryList];
}

- (IBAction)logIn:(UIButton *)sender
{
    [apiManager setupBasicAuthWithUsername:loginTextField.text password:passwordTextField.text];
    passwordTextField.text = nil;

    Authorization *auth = [Authorization new];
    auth.note = @"GitHubber";
    auth.scopes = [NSArray arrayWithObjects:@"repo", nil];
    [apiManager postAuthorization:auth withDelegate:self];
    [self loading];
}

- (IBAction)logOut:(UIButton *)sender
{
    [self loggedOut];
}

- (IBAction)resignEditing:(id)sender
{
    [authView endEditing:NO];
}

#pragma mark Private

- (void)setupManagerWithAuth:(Authorization *)auth
{
    authorization = auth;
    [apiManager setupOAuth2WithToken:authorization.token];
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
    authorization = nil;
    [keychainItem delete];
    [apiManager clearCache];

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

#pragma mark NotificationCenter

- (void)requestDidLoadResponse:(NSNotification *)notification
{
    RKResponse *resp = [notification.userInfo objectForKey:RKRequestDidLoadResponseNotificationUserInfoResponseKey];
    if (resp.isUnauthorized) {
        [self.navigationController popToViewController:self animated:YES];
        [self loggedOut];
    }
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
    NSLog(@"Error creating auth token: %@", error);
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
