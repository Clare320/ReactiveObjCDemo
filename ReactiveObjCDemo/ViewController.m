//
//  ViewController.m
//  ReactiveObjCDemo
//
//  Created by lingjie on 2020/11/9.
//

#import "ViewController.h"
#import "KVOViewController.h"
#import "Person.h"
#import <ReactiveObjC/ReactiveObjC.h>


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) dispatch_source_t jTimer;
@property (nonatomic, strong) RACSignal *tSignal;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *tAddress;

@property (nonatomic, strong) NSMutableArray *source;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self testRACSignal];
//    [self testRACSequenceFunc];
//    [self testRACSubject];
//    [self testBlock];
//    [self testRACCommand];
//    [self testRACMulticastConnection];
//    [self test];
    
//    [self testRACObserve];
    
//    [self testSignalSendError];
//    [self testSwitchToLatest];
//    [self testBasicOperators];
//    [self initUI];
    
    [self testFlatten];
}


- (void)testFlatten {
    RACSignal *normalSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@(1)];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [[normalSignal flatten] subscribeNext:^(id  _Nullable x) {
        NSLog(@"------->%@", x);
    }];
}

- (void)testSwitchToLatest {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"signal1"];
            [subscriber sendCompleted];
            return nil;
        }]];
        [subscriber sendNext:[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"signal2"];
            [subscriber sendCompleted];
            return nil;
        }]];
        [subscriber sendCompleted];
        return nil;
    }];
    
    // 原始订阅
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"origin signal:%@", x);
        [(RACSignal *)x subscribeNext:^(id  _Nullable x) {
            NSLog(@"origin sub next: %@", x);
        } completed:^{
            NSLog(@"origin sub completed!");
        }];
    } completed:^{
        NSLog(@"origin signal completed!");
    }];
    
    // map
    [[signal map:^id _Nullable(id  _Nullable value) {
        return value;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"map next:%@", x);
    } completed:^{
        NSLog(@"map completed!");
    }] ;
    
    // flattenMap
    [[signal flattenMap:^__kindof RACSignal * _Nullable(RACSignal * _Nullable value) {
        return [value map:^id _Nullable(NSString * _Nullable value) {
            return [value stringByAppendingString:@"flattenMap--map"];
        }];
    }] subscribeNext:^(RACSignal * _Nullable x) {
        NSLog(@"flattenMap next:--->%@",x);
//        [x subscribeNext:^(id  _Nullable x) {
//                    NSLog(@"flattenMap subSignal:%@", x);
//                } completed:^{
//                    NSLog(@"flattenMap subSignal completed!");
//                }];
        
    } completed:^{
        NSLog(@"flattenMap completed!");
    }] ;
    
    // flatten
    [[signal flatten] subscribeNext:^(id  _Nullable x) {
        NSLog(@"flatten:%@", x);
    } completed:^{
        NSLog(@"flatten completed!");
    }];
    
    // switchToLatest
    [[signal switchToLatest] subscribeNext:^(id  _Nullable x) {
        NSLog(@"switchLatest--->%@", x);
    } completed:^{
        NSLog(@"switchToLatest-->");
    }];
}

- (void)testBasicOperators {
    Person *p = [[Person alloc] init];
    [p setNameWithFormat:@"+ test:%@,2:%@", @"1234", @"5678"];
    NSLog(@"person->name:%@", p.name);
    
    
    RACSignal *sourceSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"source_1"];
        [subscriber sendNext:@"source_2"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *sourceSignal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"source2_1"];
        [subscriber sendNext:@"source2_2"];
        return nil;
    }];
    /*
    RACSignal *concatSignal = [sourceSignal concat:[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"other_signal_next_1"];
        return nil;
    }]];
    
    [concatSignal subscribeNext:^(NSString *  _Nullable x) {
        NSLog(@"concatSignal: %@", x);
    }];
    */
   
    /*
    RACSignal *mapSignal = [sourceSignal map:^id _Nullable(NSString *  _Nullable value) {
        return [value stringByAppendingString:@"_map"];
    }];
    [mapSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"mapSignal: %@", x);
    } completed:^{
        NSLog(@"map_completed!");
    }];
    
    [[sourceSignal flattenMap:^__kindof RACSignal * _Nullable(NSString *  _Nullable value) {
        NSString *result = [value stringByAppendingString:@"_flattenMap"];
        return [RACSignal return:result];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"flattenMap: %@", x);
    }];
    */
    
    [sourceSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"cold_signal_1:%@", x);
    }];
    
    [sourceSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"cold_signal_2:%@", x);
    }];
    
    RACSubject *hotSignal = [RACSubject subject];
    [hotSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"first: %@", x);
    }];
    [hotSignal sendNext:@"1"];
    
    [hotSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"second: %@", x);
    }];
    [hotSignal sendNext:@"2"];
}

- (void)initUI {
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height) style: UITableViewStylePlain];
    tableView.rowHeight = 150;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    UIView *remainCube = [[UIView alloc] initWithFrame:CGRectMake(width - 90, height - 130, 80, 80)];
    remainCube.backgroundColor = [UIColor redColor];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] init];
    [remainCube addGestureRecognizer: recognizer];
    [recognizer.rac_gestureSignal subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        NSLog(@"点击了cube");
    }];
    [self.view addSubview:remainCube];
    
    [self setupCornerRadius];
    [self setupLeftBarItem];
}

- (void)setupLeftBarItem {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Push KVO" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 100, 40);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        KVOViewController *vc = [[KVOViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [self.view addSubview:button];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem: barButtonItem];
}

- (void)setupCornerRadius {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 300, 100, 100)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    
//    view.layer.cornerRadius = 10;
//    view.layer.shadowColor = [UIColor grayColor].CGColor;
//    view.layer.shadowOpacity = 0.8f;
//    view.layer.shadowRadius = 5.0f;
//    view.layer.shadowOffset = CGSizeMake(0, 0);
    
//    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:10.f];
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.shadowColor = [UIColor grayColor].CGColor;
    shapeLayer.shadowOpacity = 0.8f;
    shapeLayer.shadowRadius = 5.0f;
    shapeLayer.shadowOffset = CGSizeMake(0, 0);
    view.layer.mask = shapeLayer;
}

- (void)testSignalSendError {
    RACSignal *originSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendError:[NSError errorWithDomain:@"com.happy.lingjie" code:10001 userInfo:nil]];
        return nil;
    }];
    
    [[originSignal flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                [subscriber sendNext:value];
                return nil;
            }];
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"next: %@", x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    } completed:^{
        NSLog(@"complete!");
    }];
}


- (void)testRACObserve {
    /**
        RACObserve
     */
    self.tSignal = RACObserve(self, address);
    [[self.tSignal filter:^BOOL(id  _Nullable value) {
        return  value != nil;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"---->%@", x);
    }];
    
    self.address = @"henan";
    
    RAC(self, tAddress) = self.tSignal;
    NSLog(@"tAddress: %@", self.tAddress);
}

- (void)testRACMulticastConnection {
    RACSignal *baseSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"test multicast connection");
        [subscriber sendNext:@"test"];
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
    RACMulticastConnection *connection = [baseSignal multicast:[RACReplaySubject replaySubjectWithCapacity:RACReplaySubjectUnlimitedCapacity]];
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"before: %@", x);
    }];
    [connection connect];
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"after: %@", x);
    }];
}

- (void)testRACSignal {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"---->signal sendNext");
        [subscriber sendNext:@1];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"signal disposable");
        }];
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"--->1");
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"--->2");
    }];
}

- (void)testRACCommand {
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSInteger num = [input integerValue];
//            for (NSInteger i = 0; i < num; i++) {
//                [subscriber sendNext:@(i)];
//            }
            [subscriber sendNext:@(num)];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    [[command.executionSignals switchToLatest] subscribeNext:^(id  _Nullable x) {
        NSLog(@"command: %@", x);
    }];
    
    [command execute:@1];
    
    [RACScheduler.mainThreadScheduler afterDelay:0.1 schedule:^{
        [command execute:@2];
    }];
    [RACScheduler.mainThreadScheduler afterDelay:0.2 schedule:^{
        [command execute:@3];
    }];
}

- (void)testBlock {
    void (^block)(void) = ^(void){
        NSLog(@"1234");
    };
    block();
}

- (void)testAdd:(NSInteger)value usingBlock: (NSInteger (^)(NSInteger num))block {
    
}

- (void)testRACSubject {
    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"next: %@", x);
        } completed:^{
            NSLog(@"subject completed!");
        }];
    
    [subject sendNext:@1];
    
    
}

- (void)testRACSequenceFunc {
    
    RACSequence *originSequence = @[@1, @2, @3].rac_sequence;
    
    RACSequence *sequence = [originSequence map:^id _Nullable(NSNumber *  _Nullable value) {
        return @(value.integerValue * value.integerValue);
    }];
    NSLog(@"sequence:%@", sequence);
    NSLog(@"eager:%@", sequence.eagerSequence.array);
    
    [sequence.signal subscribeNext:^(NSNumber * _Nullable x) {
        NSLog(@"signal->%@", x);
    }];
    
    NSNumber *sum = [originSequence foldLeftWithStart:0 reduce:^id _Nullable(NSNumber *  _Nullable accumulator, NSNumber * _Nullable value) {
        return @(accumulator.integerValue + value.integerValue);
    }];
    NSLog(@"sum: %@", sum);
}

- (void)testRACSequence {
    RACSequence *sequence = [RACSequence sequenceWithHeadBlock:^id _Nullable{
        return @1;
    } tailBlock:^RACSequence * _Nonnull{
        return [RACSequence sequenceWithHeadBlock:^id _Nullable{
            return @2;
        } tailBlock:^RACSequence * _Nonnull{
            return [RACSequence return:@3];
        }];
    }];
    
    RACSequence *bindSequence = [sequence bind:^RACSequenceBindBlock _Nonnull {
        return ^(NSNumber *value, BOOL *stop) {
            NSLog(@"RACSequenceBindBlock: %@", value);
            value = @(value.integerValue * 2);
            return [RACSequence return:value];
        };
    }];
    
    NSLog(@"sequence: head=(%@), tail=(%@)", sequence.head, sequence.tail);
    NSLog(@"BindSequence: head=(%@), tail=(%@)", bindSequence.head, bindSequence.tail);
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.source.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"Cell-%@", self.source[indexPath.row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.source removeObjectAtIndex:indexPath.row];
        [tableView beginUpdates];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
//        [tableView reloadData];
        [tableView endUpdates];
        [tableView reloadData];
        // iOS 11.0之后才能使用
//        [tableView performBatchUpdates:<#^(void)updates#> completion:<#^(BOOL finished)completion#>];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}


#pragma mark - Setter

- (NSMutableArray *)source {
    if (!_source) {
        _source = [NSMutableArray array];
        [_source addObjectsFromArray:@[@"a", @"b", @"c", @"d", @"e"]];
    }
    return _source;
}

- (void)dealloc {
    _jTimer = nil;
}

@end
