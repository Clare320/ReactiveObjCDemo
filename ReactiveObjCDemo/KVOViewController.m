//
//  KVOViewController.m
//  ReactiveObjCDemo
//
//  Created by lingjie on 2020/11/19.
//

#import "KVOViewController.h"
#import <WebKit/WebKit.h>
#import "Person.h"

@interface KVOViewController ()

@end

@implementation KVOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    Person *p = [[Person alloc] init];
    
    [RACObserve(p, name) subscribeNext:^(NSString *  _Nullable x) {
        NSLog(@"name:-->%@", x);
    }];
    
    p.name = @"wuming";
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
