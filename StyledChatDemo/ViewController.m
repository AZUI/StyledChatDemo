//
//  ViewController.m
//  StyledChatDemo
//
//  Created by xiaohaibo on 13-2-23.
//  Copyright (c) 2013年 xiaohaibo. All rights reserved.
//
#import "MessageStyleManager.h"
#import "ViewController.h"
#import "Message.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    [[MessageStyleManager sharedInstance] loadTemplate];
    styleArray = [[MessageStyleManager sharedInstance] availableVariants];
    
    [self.webView loadHTMLString:[MessageStyleManager sharedInstance].baseHTML baseURL:[MessageStyleManager sharedInstance].baseURL];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideShowKeyboard) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - keyboard
-(void)willShowKeyboard{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    [self.toolBar setFrame:CGRectMake(0, 480 - 260-20, 320, 44)];
    [UIView commitAnimations];
}
-(void)hideShowKeyboard{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    [self.toolBar setFrame:CGRectMake(0, 480 - 44-20, 320, 44)];
    [UIView commitAnimations];
    
}
#pragma mark
- (void)appendMessage:(Message *)msg{
    NSString *appendScript = [[MessageStyleManager sharedInstance] appendScriptForMessage:msg];

    [self.webView stringByEvaluatingJavaScriptFromString:appendScript];
    
}
#pragma mark - IBActions
- (IBAction)changeTheme:(id)sender {
    [self.view addSubview:self.settingView];
    
}
- (IBAction)cancelSetting:(id)sender {
    [self.settingView removeFromSuperview];
}
- (IBAction)send:(id)sender {
    static int i = 0;
    
    Message *msg = [[Message alloc] init];
    if (i%2 == 0) {
        msg.isOut = YES;
        msg.sender = @"me";
    }
    else{
        msg.isOut = NO;
        msg.sender = @"others";
    }
    i++;
    msg.content = self.msgTextField.text? self.msgTextField.text:@"  ";
    msg.timeStamp = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                            dateStyle:NSDateFormatterShortStyle
                                                            timeStyle:NSDateFormatterShortStyle];;
    [self appendMessage:msg];

    [self.msgTextField resignFirstResponder];
    [self.msgTextField setText:nil];
}
#pragma mark - UITableView dataSource & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return  [styleArray count];
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = [styleArray objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *selectedStyle = [styleArray objectAtIndex:indexPath.row];
    if ([selectedStyle length]) {
        [self.webView stringByEvaluatingJavaScriptFromString:[[MessageStyleManager sharedInstance] scriptForChangingVariant:selectedStyle]];
    }
    [self.settingView removeFromSuperview];
}

@end