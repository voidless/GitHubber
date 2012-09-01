#import "AuthController.h"
#import "RepositoryListController.h"
#import "Authorization.h"
#import <RestKit/RestKit.h>

@interface AuthController () <UITextFieldDelegate, RKObjectLoaderDelegate>
@end

@implementation AuthController {
    RKObjectManager *objectManager;
    CGFloat keyboardHeight;
}
@synthesize scrollView;
@synthesize contentView;
@synthesize authView;
@synthesize loginTextField;
@synthesize passwordTextField;
@synthesize loginButton;

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
    [scrollView addSubview:contentView];
    scrollView.contentSize = contentView.frame.size;

    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidUnload
{
    [self setLoginTextField:nil];
    [self setPasswordTextField:nil];
    [self setLoginButton:nil];
    [self setScrollView:nil];
    [self setContentView:nil];
    [self setAuthView:nil];
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

- (void)checkInput
{
    loginButton.enabled = loginTextField.text.length && passwordTextField.text.length;
}

#pragma mark Actions

- (IBAction)signIn:(UIButton *)sender
{
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    objectManager.client.username = loginTextField.text;
    objectManager.client.password = passwordTextField.text;

    Authorization *auth = [Authorization new];
    auth.note = @"GitHubber";
    auth.scopes = [NSArray arrayWithObjects:@"repo", nil];
    [objectManager postObject:auth delegate:self];
}

- (IBAction)resignEditing:(id)sender
{
    [contentView endEditing:NO];
}

#pragma mark RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(Authorization *)auth
{
    NSLog(@"Loaded auth: %@", auth);
    //TODO: save auth token
    objectManager.client.authenticationType = RKRequestAuthenticationTypeOAuth2;
    objectManager.client.OAuth2AccessToken = auth.token;

    RepositoryListController *repositoryListController = [RepositoryListController new];
    [self.navigationController pushViewController:repositoryListController animated:YES];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"Hit error: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    dispatch_async(dispatch_get_current_queue(), ^{
        [self.scrollView scrollRectToVisible:authView.frame animated:YES];
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
