//
//  YZLoginViewController.m
//  ez
//
//  Created by apple on 14-8-8.
//  Copyright (c) 2014年 9ge. All rights reserved.
//

#define historyAccountViewY 119

#import <TencentOpenAPI/TencentOAuth.h>
#import "YZLoginViewController.h"
#import "YZRegisterViewController.h"
#import "YZSecretChangeViewController.h"
#import "YZLoginAccountTableViewCell.h"
#import "YZStatusCacheTool.h"
#import "YZMessageLoginViewController.h"
#import "YZThirdPartyBindingViewController.h"
#import "YZLeftViewTextField.h"
#import "YZValidateTool.h"
#import "UIButton+YZ.h"
#import "YZThirdPartyStatus.h"
#import "JSON.h"
#import "WXApi.h"

@interface YZLoginViewController ()<UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,YZLoginAccountTableViewCellDelegate>

@property (nonatomic, weak) YZLeftViewTextField *accountTextField;
@property (nonatomic, weak) YZLeftViewTextField *pwdTextField;
@property (nonatomic, weak) UIButton *loginbutton;
@property (nonatomic,weak) UIButton * showPasswordButton;
@property (nonatomic, weak) UIButton *switchbtn;
@property (nonatomic, weak) UIView *historyAccountBgView;
@property (nonatomic, strong) NSArray *historyAccounts;
@property (nonatomic, weak) UITableView *historyAccountView;

@end

@implementation YZLoginViewController

#pragma mark - 控制器的生命周期
#if JG
#elif ZC
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
#elif CS
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
#endif
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"用户登录";
#if JG
    //初始化界面
    [self setupChildViews];
    self.view.backgroundColor = YZBackgroundColor;
#elif ZC
    //初始化界面
    [self setupZCChildViews];
    self.view.backgroundColor = [UIColor whiteColor];
#elif CS
    //初始化界面
    [self setupZCChildViews];
    self.view.backgroundColor = [UIColor whiteColor];
#endif
}
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setupChildViews
{
    self.navigationItem.leftBarButtonItem  = [UIBarButtonItem itemWithIcon:@"back_btn_flat" highIcon:@"back_btn_flat" target:self action:@selector(back)];
    
    //登录界面
    UIView *loginview = [[UIView alloc] initWithFrame:CGRectMake(0, 20, screenWidth, YZCellH * 2)];
    loginview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:loginview];

    //账号输入框:
    YZLeftViewTextField *accountTextField = [[YZLeftViewTextField alloc]initWithFrame:CGRectMake(YZMargin, 0, screenWidth - 2 * YZMargin, YZCellH)];
    self.accountTextField = accountTextField;
    accountTextField.placeholder = @"用户名/手机号";
    accountTextField.borderStyle = UITextBorderStyleNone;
    accountTextField.font = [UIFont systemFontOfSize:YZGetFontSize(28)];
    accountTextField.textColor = YZBlackTextColor;
    accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [loginview addSubview:accountTextField];
    
    UIImageView * leftImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 18, 18)];
    leftImageView1.image = [UIImage imageNamed:@"login_account_icon"];
    accountTextField.leftView = leftImageView1;
    accountTextField.leftViewMode = UITextFieldViewModeAlways;
    //历史账户按钮
    self.historyAccounts = [YZStatusCacheTool getAccounts];//获取所有历史用户账户
    if(self.historyAccounts.count)//有历史账户才显示按钮
    {
        UIButton *historyUserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat historyUserBtnW = 16;
        CGFloat historyUserBtnH = 8;
        historyUserBtn.frame = CGRectMake(screenWidth - YZMargin - historyUserBtnW, (YZCellH - historyUserBtnH) / 2, historyUserBtnW, historyUserBtnH);
        UIImage *historyUserBtnImage = [UIImage imageNamed:@"historyAccountBtn"];
        [historyUserBtn setImage:historyUserBtnImage forState:UIControlStateNormal];
        [historyUserBtn addTarget:self action:@selector(historyUserBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [loginview addSubview:historyUserBtn];
        accountTextField.frame = CGRectMake(YZMargin, 0, screenWidth - 2 * YZMargin - 18 - 5, YZCellH);
    }
    
    //分割线
    UIView *seperator = [[UIView alloc] init];
    seperator.frame = CGRectMake(0, YZCellH - 1, screenWidth, 1);
    seperator.backgroundColor = YZWhiteLineColor;
    [loginview addSubview:seperator];
    
    //密码输入框:
    YZLeftViewTextField *pwdTextField = [[YZLeftViewTextField alloc]initWithFrame:CGRectMake(YZMargin, YZCellH, screenWidth - 2 * YZMargin, YZCellH)];
    self.pwdTextField = pwdTextField;
    pwdTextField.borderStyle = UITextBorderStyleNone;
    pwdTextField.placeholder = @"登录密码";
    pwdTextField.font = [UIFont systemFontOfSize:YZGetFontSize(28)];
    pwdTextField.textColor = YZBlackTextColor;
    pwdTextField.secureTextEntry = YES;
    pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [loginview addSubview:pwdTextField];
    
    UIImageView * leftImageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 18, 18)];
    leftImageView2.image = [UIImage imageNamed:@"login_passWord_icon"];
    pwdTextField.leftView = leftImageView2;
    pwdTextField.leftViewMode = UITextFieldViewModeAlways;
    
    //自动登录按钮
    UIButton *switchbtn = [[UIButton alloc] init];
    self.switchbtn = switchbtn;
    [switchbtn setImage:[UIImage imageNamed:@"bet_weixuanzhong"] forState:UIControlStateNormal];
    [switchbtn setImage:[UIImage imageNamed:@"bet_xuanzhong"] forState:UIControlStateSelected];
    [switchbtn setImage:[UIImage imageNamed:@"bet_xuanzhong"] forState:UIControlStateHighlighted];
    switchbtn.selected = YES;
    [switchbtn setTitle:@"自动登录" forState:UIControlStateNormal];
    [switchbtn setTitleColor:YZBlackTextColor forState:UIControlStateNormal];
    switchbtn.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    switchbtn.frame = CGRectMake(YZMargin, CGRectGetMaxY(loginview.frame) + 10, 85, 20);
    [switchbtn setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft imgTextDistance:5];
    int autoLoginType = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"autoLogin"];
    if (autoLoginType == 0) {//默认自动登录
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:2 forKey:@"autoLogin"];
        [defaults synchronize];
    }
    if(autoLoginType == 1)
    {
        switchbtn.selected = NO;
    }else
    {
        switchbtn.selected = YES;//默认值或者设置位自动
    }
    [switchbtn addTarget:self action:@selector(clickswitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchbtn];
    
    //忘记密码
    UIButton *keybutton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat keybuttonY = CGRectGetMaxY(loginview.frame) + 10;
    keybutton.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    [keybutton setTitleColor:YZBlueBallColor forState:UIControlStateNormal];
    [keybutton setTitle:@"忘记密码" forState:UIControlStateNormal];
    CGSize keybuttonSize = [keybutton.currentTitle sizeWithLabelFont:keybutton.titleLabel.font];
    keybutton.frame = CGRectMake(screenWidth - YZMargin - keybuttonSize.width, keybuttonY, keybuttonSize.width, 20);
    [keybutton addTarget:self action:@selector(ketbtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:keybutton];

    //登录按钮
    YZBottomButton *loginbutton = [YZBottomButton buttonWithType:UIButtonTypeCustom];
    self.loginbutton = loginbutton;
    loginbutton.y = CGRectGetMaxY(loginview.frame) + 60;
    [loginbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginbutton setTitle:@"登录" forState:UIControlStateNormal];
    [loginbutton addTarget:self action:@selector(loginBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginbutton];
    
    //注册按钮
    UIButton *registerbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerbtn.frame = CGRectMake(loginbutton.x, CGRectGetMaxY(loginbutton.frame) + 20, screenWidth - loginbutton.x * 2, 40);
    registerbtn.backgroundColor = [UIColor whiteColor];
    [registerbtn setTitleColor:YZBlackTextColor forState:UIControlStateNormal];
    [registerbtn setTitle:@"注册" forState:UIControlStateNormal];
    registerbtn.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(28)];
    [registerbtn addTarget:self action:@selector(registerPressed) forControlEvents:UIControlEventTouchUpInside];
    registerbtn.layer.masksToBounds = YES;
    registerbtn.layer.cornerRadius = 3;
    registerbtn.layer.borderWidth = 0.8;
    registerbtn.layer.borderColor = YZGrayLineColor.CGColor;
    [self.view addSubview:registerbtn];
    
    UIButton * messageLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    messageLoginButton.tag = 1;
    [messageLoginButton setTitle:@"短信验证码登录" forState:UIControlStateNormal];
    [messageLoginButton setTitleColor:YZColor(83, 83, 83, 1) forState:UIControlStateNormal];
    messageLoginButton.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    CGSize messageLoginButtonSize = [messageLoginButton.currentTitle sizeWithLabelFont:messageLoginButton.titleLabel.font];
    CGFloat messageLoginButtonW = messageLoginButtonSize.width;
    CGFloat messageLoginButtonH = messageLoginButtonSize.height;
    CGFloat messageLoginButtonX = screenWidth - messageLoginButtonW - loginbutton.x;
    CGFloat messageLoginButtonY = CGRectGetMaxY(registerbtn.frame) + 20;
    messageLoginButton.frame = CGRectMake(messageLoginButtonX, messageLoginButtonY, messageLoginButtonW, messageLoginButtonH);
    [messageLoginButton addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:messageLoginButton];
    
    //第三方登录
    CGFloat thirdPartyBtnWH = 35;
    
    UILabel * promptLabel = [[UILabel alloc]init];
    promptLabel.text = @"合作账户登录";
    promptLabel.font = [UIFont systemFontOfSize:YZGetFontSize(22)];
    promptLabel.textColor = YZColor(134, 134, 134, 1);
    CGSize promptSize = [promptLabel.text sizeWithLabelFont:promptLabel.font];
    CGFloat promptLabelX = (screenWidth - promptSize.width) / 2;
    CGFloat promptLabelY = screenHeight - statusBarH - navBarH - [YZTool getSafeAreaBottom] - thirdPartyBtnWH - 40 - promptSize.height;
    promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptSize.width, promptSize.height);
    [self.view addSubview:promptLabel];
    
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(50, 0, promptLabel.x - 50 - 10, 1)];
    line1.center = CGPointMake(line1.center.x, promptLabel.center.y);
    line1.backgroundColor = YZGrayLineColor;
    [self.view addSubview:line1];
    
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(promptLabel.frame) + 10, 0, screenWidth - CGRectGetMaxX(promptLabel.frame) - 10 - 50, 1)];
    line2.center = CGPointMake(line2.center.x, promptLabel.center.y);
    line2.backgroundColor = YZGrayLineColor;
    [self.view addSubview:line2];

    //登录按钮
    NSMutableArray *thirdPartyBtnImages = [NSMutableArray array];
    NSMutableArray *thirdPartyBtnSelectedImages = [NSMutableArray array];
    if ([WXApi isWXAppInstalled]) {//如果安装微信
        [thirdPartyBtnImages addObject:@"login_weixin_icon"];
        [thirdPartyBtnSelectedImages addObject:@"login_weixin_icon_selected"];
    }

    if ([TencentOAuth iphoneQQInstalled]) {//如果安装QQ
        [thirdPartyBtnImages addObject:@"login_qq_icon"];
        [thirdPartyBtnSelectedImages addObject:@"login_qq_icon_selected"];
    }
    //微博
    [thirdPartyBtnImages addObject:@"login_sina_icon"];
    [thirdPartyBtnSelectedImages addObject:@"login_sina_icon_selected"];
    
    CGFloat padding = (screenWidth - thirdPartyBtnImages.count * thirdPartyBtnWH) / (thirdPartyBtnImages.count + 1);//边距
    UIButton * lastThirdPartyBtn;
    for (int i = 0; i < thirdPartyBtnImages.count; i++) {
        CGFloat thirdPartyBtnY = screenHeight  - [YZTool getSafeAreaBottom] - thirdPartyBtnWH - statusBarH - navBarH - 25;
        UIButton *thirdPartyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        thirdPartyBtn.frame = CGRectMake(CGRectGetMaxX(lastThirdPartyBtn.frame) + padding, thirdPartyBtnY, thirdPartyBtnWH, thirdPartyBtnWH);
        [thirdPartyBtn setImage:[UIImage imageNamed:thirdPartyBtnImages[i]] forState:UIControlStateNormal];
        [thirdPartyBtn setImage:[UIImage imageNamed:thirdPartyBtnSelectedImages[i]] forState:UIControlStateHighlighted];
        if ([thirdPartyBtnImages[i] isEqual:@"login_weixin_icon"]) {
            thirdPartyBtn.tag = 101;
        }else if ([thirdPartyBtnImages[i] isEqual:@"login_qq_icon"])
        {
            thirdPartyBtn.tag = 102;
        }else if ([thirdPartyBtnImages[i] isEqual:@"login_sina_icon"])
        {
            thirdPartyBtn.tag = 103;
        }
        [thirdPartyBtn addTarget:self action:@selector(thirdPartyBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:thirdPartyBtn];
        lastThirdPartyBtn = thirdPartyBtn;
    }

    //如果记住了账号密码,就显示密码
    accountTextField.text = [YZUserDefaultTool getObjectForKey:@"userName"];
    if([YZUserDefaultTool getObjectForKey:@"userPwd"])
    {
        pwdTextField.text = [YZUserDefaultTool getObjectForKey:@"userPwd"];
    }
}

- (void)setupZCChildViews
{
    //close
    UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat closeButtonWH = 30;
    closeButton.frame = CGRectMake(screenWidth - closeButtonWH - 10, statusBarH + 10, closeButtonWH, closeButtonWH);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"login_close_icon"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    //login
    UIImageView * logoImageView = [[UIImageView alloc] init];
    CGFloat logoImageViewW = 197;
    CGFloat logoImageViewH = 107;
    logoImageView.frame = CGRectMake((screenWidth - logoImageViewW) / 2, statusBarH + 50, logoImageViewW, logoImageViewH);
#if ZC
    logoImageView.image = [UIImage imageNamed:@"login_ad_zc"];
#elif CS
    logoImageView.image = [UIImage imageNamed:@"login_ad_cs"];
#endif
    [self.view addSubview:logoImageView];
    
    UIView * lastView;
    //输入框
    NSArray * placeholders = @[@"用户名/手机号",@"登录密码"];
    CGFloat textFieldH = 52;
    
    for (int i = 0; i < 2; i++) {
        YZLeftViewTextField * textField = [[YZLeftViewTextField alloc] init];
        textField.font = [UIFont systemFontOfSize:YZGetFontSize(30)];
        textField.textColor = YZBlackTextColor;
        textField.placeholder = placeholders[i];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.borderStyle = UITextBorderStyleNone;
        CGFloat textFieldX = YZMargin;
        CGFloat textFieldY = CGRectGetMaxY(logoImageView.frame) + 34;
        CGFloat textFieldW = screenWidth - 2 * textFieldX;
        if (i == 0) {//账号
            self.accountTextField = textField;
        }else//密码
        {
            self.pwdTextField = textField;
            textFieldX += 30;
            textFieldY = CGRectGetMaxY(lastView.frame);
            textFieldW -= 2 * 30;
            textField.secureTextEntry = YES;
        }
        textField.frame = CGRectMake(textFieldX, textFieldY, textFieldW, textFieldH);
        [self.view addSubview:textField];
        lastView = textField;
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(YZMargin, CGRectGetMaxY(textField.frame) - 1, screenWidth - 2 * YZMargin, 1)];
        line.backgroundColor = YZWhiteLineColor;
        [self.view addSubview:line];
    }
    self.accountTextField.text = [YZUserDefaultTool getObjectForKey:@"userName"];
    
    UIButton * showPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.showPasswordButton = showPasswordButton;
    CGFloat showPasswordButtonWH = 20;
    showPasswordButton.frame = CGRectMake(screenWidth - showPasswordButtonWH - YZMargin, 0, showPasswordButtonWH, showPasswordButtonWH);
    showPasswordButton.centerY = self.pwdTextField.centerY;
    [showPasswordButton setBackgroundImage:[UIImage imageNamed:@"login_password_invisible"] forState:UIControlStateNormal];
    [showPasswordButton setBackgroundImage:[UIImage imageNamed:@"login_password_visible"] forState:UIControlStateSelected];
    [showPasswordButton addTarget:self action:@selector(showPasswordButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showPasswordButton];
    
    //登录按钮
    YZBottomButton * loginBtn = [YZBottomButton buttonWithType:UIButtonTypeCustom];
    self.loginbutton = loginBtn;
    loginBtn.y = CGRectGetMaxY(lastView.frame) + 30;
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.layer.masksToBounds = YES;
    loginBtn.layer.cornerRadius = loginBtn.height / 2;
    [loginBtn addTarget:self action:@selector(loginBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    //注册按钮
    UIButton * registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake(loginBtn.x, CGRectGetMaxY(loginBtn.frame) + 20, screenWidth - 2 * loginBtn.x, 40);
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:YZRedTextColor forState:UIControlStateNormal];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(28)];
    registerBtn.layer.masksToBounds = YES;
    registerBtn.layer.cornerRadius = loginBtn.height / 2;
    registerBtn.layer.borderColor = YZBaseColor.CGColor;
    registerBtn.layer.borderWidth = 1;
    [registerBtn addTarget:self action:@selector(registerPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
    lastView = registerBtn;
    
    //忘记密码
    for (int i = 0; i < 2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button setTitle:@"忘记密码?" forState:UIControlStateNormal];
        if (i == 1)
        {
            [button setTitle:@"短信验证码登录" forState:UIControlStateNormal];
        }
        [button setTitleColor:YZColor(83, 83, 83, 1) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
        CGSize buttonSize = [button.currentTitle sizeWithLabelFont:button.titleLabel.font];
        CGFloat buttonW = buttonSize.width;
        CGFloat buttonH = buttonSize.height;
        CGFloat buttonX = loginBtn.x;
        if (i == 1)
        {
            buttonX = screenWidth - buttonW - buttonX;
        }
        CGFloat buttonY = CGRectGetMaxY(lastView.frame) + 20;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    //默认自动登录
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:2 forKey:@"autoLogin"];
    [defaults synchronize];
    
    //第三方登录
    UIView *thirdPartyView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - [YZTool getSafeAreaBottom] - 83, screenWidth, 83)];
    thirdPartyView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:thirdPartyView];
    
    UILabel * promptLabel = [[UILabel alloc]init];
    promptLabel.text = @"or";
    promptLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    promptLabel.textColor = YZDrayGrayTextColor;
    CGSize promptSize = [promptLabel.text sizeWithLabelFont:promptLabel.font];
    CGFloat promptLabelX = (screenWidth - promptSize.width) / 2;
    promptLabel.frame = CGRectMake(promptLabelX, 0, promptSize.width, promptSize.height);
    [thirdPartyView addSubview:promptLabel];
    
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(10, 0, promptLabel.x - 10 - 10, 1)];
    line1.centerY = promptLabel.centerY;
    line1.backgroundColor = YZWhiteLineColor;
    [thirdPartyView addSubview:line1];
    
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(promptLabel.frame) + 10, 0, screenWidth - CGRectGetMaxX(promptLabel.frame) - 10 - 10, 1)];
    line2.centerY = promptLabel.centerY;
    line2.backgroundColor = YZWhiteLineColor;
    [thirdPartyView addSubview:line2];
    
    CGFloat thirdPartyBtnWH = 38;
    CGFloat thirdPartyBtnY = thirdPartyView.height - 17 - thirdPartyBtnWH;
    NSMutableArray *thirdPartyBtnImages = [NSMutableArray array];
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {//如果安装微信
        [thirdPartyBtnImages addObject:@"login_weixin_icon"];
//    }
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {//如果安装QQ
        [thirdPartyBtnImages addObject:@"login_qq_icon"];
//    }
    //微博
    [thirdPartyBtnImages addObject:@"login_sina_icon"];
    CGFloat thirdPartyBtnPadding = (screenWidth - thirdPartyBtnWH * thirdPartyBtnImages.count) / (thirdPartyBtnImages.count + 1);
    if (thirdPartyBtnImages.count == 0) {
        thirdPartyView.hidden = YES;
    }
    for (int i = 0; i < thirdPartyBtnImages.count; i++) {
        UIButton * thirdPartyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        thirdPartyBtn.frame = CGRectMake(thirdPartyBtnPadding + (thirdPartyBtnWH + thirdPartyBtnPadding) * i, thirdPartyBtnY, thirdPartyBtnWH, thirdPartyBtnWH);
        if ([thirdPartyBtnImages[i] isEqualToString:@"login_qq_icon"]) {
            thirdPartyBtn.tag = 102;
        }else if ([thirdPartyBtnImages[i] isEqualToString:@"login_weixin_icon"]) {
            thirdPartyBtn.tag = 101;
        }else if ([thirdPartyBtnImages[i] isEqualToString:@"login_sina_icon"]) {
            thirdPartyBtn.tag = 103;
        }
        [thirdPartyBtn setBackgroundImage:[UIImage imageNamed:thirdPartyBtnImages[i]] forState:UIControlStateNormal];
        [thirdPartyBtn addTarget:self action:@selector(thirdPartyBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [thirdPartyView addSubview:thirdPartyBtn];
    }
}
    
#pragma mark - 点击按钮
- (void)buttonDidClick:(UIButton *)button
{
    if (button.tag == 0) {//忘记密码?
        [self ketbtnPressed];
    }else//短信验证码登录
    {
        [self messageLogin];
    }
}
    
- (void)showPasswordButtonDidClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        self.pwdTextField.secureTextEntry = NO;
    } else
    {
        self.pwdTextField.secureTextEntry = YES;
    }
}

- (void)clickswitch:(UIButton *)btn
{
    btn.selected = !btn.selected;
    [self setLoginType:btn.selected];
}
- (void)setLoginType:(BOOL)isSelected
{
    int autoLoginType = 0;
    if(isSelected)
    {
        autoLoginType = 2;
    }else
    {
        autoLoginType = 1;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:autoLoginType forKey:@"autoLogin"];
    [defaults synchronize];
}
#pragma mark - 点击短信验证码登录
-(void)messageLogin
{
    YZMessageLoginViewController *messageLoginVC = [[YZMessageLoginViewController alloc] init];
    [self.navigationController pushViewController:messageLoginVC animated:YES];
}
    
#pragma mark - 点击注册按钮
-(void)registerPressed
{
    YZRegisterViewController *registerVc = [[YZRegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVc animated:YES];
}
    
#pragma mark - 点击忘记密码按钮
-(void)ketbtnPressed
{
    YZSecretChangeViewController *secretVc = [[YZSecretChangeViewController alloc] init];
    [self.navigationController pushViewController:secretVc animated:YES];
}
    
#pragma mark - 历史用户按钮点击
- (void)historyUserBtnClick
{
    [self.view endEditing:YES];
    self.historyAccounts = [YZStatusCacheTool getAccounts];//获取所有历史用户账户
    
    UIView *historyAccountBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.historyAccountBgView = historyAccountBgView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeHistoryBgview)];
    tap.delegate = self;
    [historyAccountBgView addGestureRecognizer:tap];
    [self.navigationController.view addSubview:historyAccountBgView];
    
    UITableView *historyAccountView = [[UITableView alloc] initWithFrame:CGRectMake(0, historyAccountViewY, 278.5, 300)];
    self.historyAccountView = historyAccountView;
    historyAccountView.center = CGPointMake(screenWidth/2, historyAccountView.center.y);
    historyAccountView.delegate = self;
    historyAccountView.dataSource = self;
    historyAccountView.tableFooterView = [[UIView alloc] init];
    historyAccountView.separatorColor = YZWhiteLineColor;
    [historyAccountView setEstimatedSectionHeaderHeightAndFooterHeight];
    historyAccountView.scrollEnabled = NO;
    [historyAccountBgView addSubview:historyAccountView];
}
- (void)removeHistoryBgview
{
    [self.historyAccountBgView removeFromSuperview];
    self.historyAccountBgView = nil;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint pos = [touch locationInView:self.historyAccountView.superview];
        if (CGRectContainsPoint(self.historyAccountView.frame, pos)) {
            return NO;
        }
    }
    return YES;
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = (int)self.historyAccounts.count;
    CGFloat maxH = screenHeight - historyAccountViewY - 40;
    CGFloat height = 44 * count;
    tableView.height = height < maxH ? height : maxH;
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YZLoginAccountTableViewCell *cell = [YZLoginAccountTableViewCell cellWithTableView:tableView];
    cell.historyAccount = self.historyAccounts[indexPath.row];
    cell.delegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.accountTextField.text = self.historyAccounts[indexPath.row];
    self.pwdTextField.text = @"";
    [self removeHistoryBgview];
}
//YZLoginAccountTableViewCellDelegate
- (void)loginAccountCellDidClickAccountDeleteBtn:(UIButton *)btn inCell:(YZLoginAccountTableViewCell *)cell
{
    NSIndexPath * indexPath = [self.historyAccountView indexPathForCell:cell];
    [YZStatusCacheTool deleteAccount:self.historyAccounts[indexPath.row]];
    self.historyAccounts = [YZStatusCacheTool getAccounts];//获取所有历史用户账户
    //删除cell
    NSArray *arr = [NSArray arrayWithObject:indexPath];
    [self.historyAccountView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationTop];
}
#pragma  mark - 点击登录按钮
- (void)loginBtnPressed
{
    [self.view endEditing:YES];
    if (YZStringIsEmpty(self.accountTextField.text)) {
        [MBProgressHUD showError:@"请输入用户名"];
        return;
    }
    if (YZStringIsEmpty(self.pwdTextField.text)) {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    if(![YZValidateTool validateUserName:self.accountTextField.text])
    {
        [MBProgressHUD showError:@"您输入的用户名格式不对"];
        return;
    }
    if(![YZValidateTool validatePassword:self.pwdTextField.text])
    {
        [MBProgressHUD showError:@"您输入的密码格式不对"];
        return;
    }
    [MBProgressHUD showMessage:@"正在登录,客官请稍后" toView:self.view];
    NSDictionary *dict = @{
                           @"cmd":@(8004),
                           @"userName":self.accountTextField.text,
                           @"password":self.pwdTextField.text,
                           @"loginType":@(1)
                           };
    [[YZHttpTool shareInstance] postWithParams:dict success:^(id json) {
        YZLog(@"json = %@",json);
        [MBProgressHUD hideHUDForView:self.view];
        //检查账号密码返回数据
        [self checkloginWith:json];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
    }];
}
- (void)checkloginWith:(id)json
{
    if(SUCCESS)
    {//成功登录
        //保存用户信息
        YZUser *user = [YZUser objectWithKeyValues:json];
        [YZUserDefaultTool saveUser:user];
        [YZUserDefaultTool saveObject:@"accountLogin" forKey:@"loginWay"];
        //存储userId和userName
        [YZUserDefaultTool saveObject:json[@"userId"] forKey:@"userId"];
        
        //根据保存密码按钮状态，保存密码
        [YZUserDefaultTool saveObject:self.accountTextField.text forKey:@"userName"];//userAccount
        //更新自动登录状态
        int autoLoginType = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"autoLogin"];
        if(autoLoginType == 2)
        {
            [YZUserDefaultTool saveObject:self.pwdTextField.text forKey:@"userPwd"];
            YZLog(@"accountTextField = %@,pwdTextField = %@",self.accountTextField.text,self.pwdTextField.text);
        }else
        {
            [YZUserDefaultTool removeObjectForKey:@"userPwd"];
        }
        //存储账户到数据库
        [YZStatusCacheTool saveAccount:self.accountTextField.text];
        //发送登录成功通知
        [[NSNotificationCenter defaultCenter] postNotificationName:loginSuccessNote object:nil];
        [self loadUserInfo];
        [YZTool setAlias];
        [self back];
    }else
    {
        ShowErrorView
        [MBProgressHUD hideHUDForView:self.view];
    }
}

#pragma mark - 第三方登录
- (void)thirdPartyBtnDidClick:(UIButton *)btn
{
    //微信注册
#if JG
    [WXApi registerApp:WXAppIdOld withDescription:@"九歌彩票"];
#elif ZC
    [WXApi registerApp:WXAppIdOld withDescription:@"中彩啦"];
#elif CS
    [WXApi registerApp:WXAppIdOld withDescription:@"财多多"];
#endif
    UMSocialPlatformType platformType;
    if (btn.tag == 101)
    {
        platformType = UMSocialPlatformType_WechatSession;
    }else if (btn.tag == 102)
    {
        platformType = UMSocialPlatformType_QQ;
    }else {
        platformType = UMSocialPlatformType_Sina;
    }
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:nil completion:^(id result, NSError *error) {
        if (!error) {
            [self getBindStatusWithUserInfoResponse:result platformType:platformType];
        }else
        {
            [MBProgressHUD showError:@"授权失败"];
        }
    }];
}
//获取绑定信息
- (void)getBindStatusWithUserInfoResponse:(UMSocialUserInfoResponse *)resp  platformType:(UMSocialPlatformType)platformType
{
    if (!resp || !resp.uid || !resp.openid) {
        return;
    }
    NSString * paramJson;
    NSNumber *type;
    if (platformType == UMSocialPlatformType_WechatSession) {
        paramJson = [@{@"uId":resp.uid,@"openId":resp.openid} JSONRepresentation];
        type = @(2);
    }else if (platformType == UMSocialPlatformType_QQ)
    {
        paramJson = [@{@"uId":resp.uid,@"openId":resp.openid} JSONRepresentation];
        type = @(1);
    }else if (platformType == UMSocialPlatformType_Sina)//微博登录只需uid
    {
        paramJson = [@{@"uId":resp.uid} JSONRepresentation];
        type = @(3);
    }
    NSString * imei = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    waitingView
    NSDictionary *dict = @{
                           @"cmd":@(10630),
                           @"type":type,
                           @"param":paramJson,
                           @"imei":imei
                           };
    [[YZHttpTool shareInstance] postWithParams:dict success:^(id json) {
        YZLog(@"json = %@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [self checkThirdPartyLoginWithUserInfoResponse:resp json:json type:type param:paramJson imei:imei];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
    }];
}

- (void)checkThirdPartyLoginWithUserInfoResponse:(UMSocialUserInfoResponse *)resp json:(id)json type:(NSNumber *)type param:(NSString *)param imei:(NSString *)imei
{
    if (SUCCESS) {
        YZThirdPartyStatus *thirdPartyStatus = [[YZThirdPartyStatus alloc]init];
        thirdPartyStatus.name = resp.name;
        thirdPartyStatus.iconurl = resp.iconurl;
        thirdPartyStatus.gender = resp.gender;
        thirdPartyStatus.uid = resp.uid;
        thirdPartyStatus.openid = resp.openid;
        thirdPartyStatus.refreshToken = resp.refreshToken;
        thirdPartyStatus.expiration = resp.expiration;
        thirdPartyStatus.accessToken = resp.accessToken;
        thirdPartyStatus.platformType = resp.platformType;
        thirdPartyStatus.originalResponse = resp.originalResponse;
        if([json[@"bindStatus"] isEqualToNumber:@(0)])//未绑定
        {
            //检查账号密码返回数据
            YZThirdPartyBindingViewController * thirdPartyBindingVC = [[YZThirdPartyBindingViewController alloc]init];
            thirdPartyBindingVC.type = type;
            thirdPartyBindingVC.param = param;
            thirdPartyBindingVC.imei = imei;
            thirdPartyBindingVC.thirdPartyStatus = thirdPartyStatus;
            [self.navigationController pushViewController:thirdPartyBindingVC animated:YES];
        }else
        {
            [YZUserDefaultTool saveObject:json[@"userId"] forKey:@"userId"];
            [YZUserDefaultTool saveObject:@"thirdPartyLogin" forKey:@"loginWay"];
            [YZUserDefaultTool saveThirdPartyStatus:thirdPartyStatus];
            //更新自动登录状态
            int autoLoginType = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"autoLogin"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:autoLoginType forKey:@"autoLogin"];
            [defaults synchronize];
            //用于绑定Alias的
            [YZTool setAlias];
            //发送登录成功通知
            [[NSNotificationCenter defaultCenter] postNotificationName:loginSuccessNote object:nil];
            [self loadUserInfo];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else
    {
        ShowErrorView;
    }
}
- (void)loadUserInfo
{
    if (!UserId)
    {
        return;
    }
    NSDictionary *dict = @{
                           @"cmd":@(8006),
                           @"userId":UserId
                           };
    [[YZHttpTool shareInstance] requestTarget:self PostWithParams:dict success:^(id json) {
        YZLog(@"%@",json);
        if (SUCCESS) {
            //存储用户信息
            YZUser *user = [YZUser objectWithKeyValues:json];
            [YZUserDefaultTool saveUser:user];
        }
    } failure:^(NSError *error) {
        YZLog(@"账户error");
    }];
}

@end
