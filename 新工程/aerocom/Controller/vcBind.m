//
//  vcBind.m
//  aerocom
//
//  Created by 丁付德 on 15/7/13.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBind.h"
#import "tvcBind.h"

const NSInteger stanTime = 10;

@interface vcBind () <UITableViewDelegate, UITableViewDataSource, tvcBindDelegate>
{
    NSRecursiveLock *theLock;
    NSDate *beginDate;
}

//@property (nonatomic, strong) NSMutableArray *arrData;

@property (strong, atomic) NSMutableDictionary *dicData;             // 数据源

@property (nonatomic, strong) UITableView *tabView;

@end

@implementation vcBind

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:self title:@"植物绑定"];
    
    [self initData];
    [self initTable];
    
    [self refreshRightButton];
    
    UITapGestureRecognizer *recognizer;
    recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setNumberOfTapsRequired:1];
    [[self view] addGestureRecognizer:recognizer];
    beginDate = [NSDate date];
}

-(void)initData
{
    if (self.per) {
        self.dicData =  [@{ self.per.perUUIDString:self.per }mutableCopy];//[@[self.per] mutableCopy];
    }
    else
    {
        self.dicData = [NSMutableDictionary new];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.per)
    {
        [self rightButtonClick];
    }
}

-(void)refreshRightButton
{
    if (!self.per) {
        [self initRightButton:nil imgName:@"shuaxin"];
    }else
    {
        [self initRightButton:nil imgName:nil];
    }
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    [self.Bluetooth stopScan];
}

-(void)back
{
    [self.delegate bind:self.per];
    [super back];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.Bluetooth stopScan];
    [super viewWillDisappear:animated];
}

-(void)Found_Next:(NSMutableDictionary *)recivedTxt
{
    if (self.per) {
        return;
    }
    
    //NSLog(@"发现的 %@", recivedTxt);
    __block vcBind *blockSelf = self;
    __block NSMutableDictionary *blockrecivedTxt = recivedTxt;
    
    NextWaitInMain(
       NSDate *now = [NSDate date];
       if ([now timeIntervalSinceDate:beginDate] > 1 && blockSelf.dicData.count < blockrecivedTxt.count) //  && _dicData.count > lastCount
       {
           [blockSelf.dicData  removeAllObjects];
           NSMutableDictionary *dicFound = [[NSMutableDictionary alloc] initWithDictionary:blockrecivedTxt];
           
           for (int i = 0; i < dicFound.count; i++) {
               CBPeripheral *cbp = dicFound.allValues[i];
               Per *per = [Per new];
               per.perName = cbp.name;
               per.perUUIDString = dicFound.allKeys[i];
               per.isBind = NO;
               
               [blockSelf.dicData setObject:per forKey:per.perUUIDString];
           }
           [blockSelf.tabView reloadData];
       });
    
    
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        @synchronized(self.arrData)
//        {
//            [self.arrData  removeAllObjects];
//            NSMutableDictionary *dicFound = [[NSMutableDictionary alloc] initWithDictionary:recivedTxt];
//            
//            for (int i = 0; i < dicFound.count; i++) {
//                CBPeripheral *cbp = dicFound.allValues[i];
//                Per *per = [Per new];
//                per.perName = cbp.name;
//                per.perUUIDString = dicFound.allKeys[i];
//                per.isBind = NO;
//                
//                [self.arrData addObject:per];
//            }
//            
//            [self.tabView reloadData];
//            sleep(0.3);
//        } 
//    });
}


-(void)initTable
{
    self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.tabView.dataSource = self;
    self.tabView.delegate = self;
    self.tabView.rowHeight = 50;
    self.tabView.showsVerticalScrollIndicator = NO;
    self.tabView.scrollEnabled = NO;
    self.tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcBind" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    [self.view addSubview:self.tabView];
}

-(void)rightButtonClick
{
    if (!self.per)
    {
        beginDate = [NSDate date];
        [self.dicData removeAllObjects];
        [self.Bluetooth startScan];
        __block vcBind *blockSelf = self;
        NextWait([blockSelf.Bluetooth stopScan];, stanTime);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.dicData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    tvcBind *cell = [tvcBind cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    Per *per = self.dicData.allValues[indexPath.row];
    cell.per = per;
    cell.tag = indexPath.row;
    
    return cell;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    [self.Bluetooth stopScan];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

#pragma mark tvcBindDelegate
-(void)binding:(Per *)per
{
    if (per.isBind)
    {
        [self.dicData removeObjectForKey:self.per.perUUIDString];
        self.per = nil;
        [self rightButtonClick];
        [self refreshRightButton];
        [self.tabView reloadData];
    }
    else
    {
        [self.Bluetooth stopScan];
        per.isBind = YES;
        self.per = per;
        //LMBShow(@"绑定成功");
        [self back];
        //NextWait([self back];, 1);
    }
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
