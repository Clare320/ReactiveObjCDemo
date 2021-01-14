//
//  KitViewController.m
//  ReactiveObjCDemo
//
//  Created by lingjie on 2020/11/11.
//

#import "KitViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface KitViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *anotherTextField;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *codeButton;

@property (strong, nonatomic) RACDisposable *timerDisposable;
@property (assign, nonatomic) NSTimeInterval timeInterval;
@property (copy, nonatomic) NSString *address;
@end

@implementation KitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    @weakify(self);
    [self.textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        self.contentLabel.text = x;
    }];
    
    [self testLoginButtonWithRACCommand];
    [self testRACTimer];
}

- (void)testLoginButtonWithRACCommand {
    @weakify(self);
    RAC(self.loginButton, enabled) = [RACSignal combineLatest:@[
      self.textField.rac_textSignal,
    ] reduce:^(NSString *text) {
        return @(text.length > 0);
    }];
    
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIButton * _Nullable button) {
//        @strongify(self);
        
        NSLog(@"click login button");
    }];
}

- (void)testRACTimer {
    @weakify(self);
    [[self.codeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIButton * _Nullable button) {
        @strongify(self);
        button.enabled = NO;
        self.timeInterval = 10;
        self.timerDisposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
            self.timeInterval -= 1;
            NSString *title = self.timeInterval > 0 ? [NSString stringWithFormat:@"请等待%.1f秒后重试", self.timeInterval] : @"send code";
            [self.codeButton setTitle:title forState:UIControlStateNormal | UIControlStateDisabled];
           
            if (self.timeInterval == 0) {
                button.enabled = YES;
                [self.timerDisposable dispose];
            }
        }];
    }];
}

- (void)testRACCommandBingingToButton {
    // RACCommand使用
    @weakify(self);
    self.loginButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"Login"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
//                NSLog(@"login disposable");
            }];
        }];
    }];
    

    [self.loginButton.rac_command.executionSignals subscribeNext:^(RACSignal<id> * _Nullable x) {
        [x subscribeCompleted:^{
            @strongify(self);
            self.address = @"putuo";
            NSLog(@"login completed!");
        }];
    }];
    
    [[RACObserve(self, address) filter:^BOOL(NSString * _Nullable value) {
        return value != nil;
    }] subscribeNext:^(NSString *  _Nullable address) {
        NSLog(@"observe:%@", address);
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
