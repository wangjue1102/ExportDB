//
//  ViewController.m
//  ExportDB
//
//  Created by wangjueMBP on 2016/10/27.
//  Copyright © 2016年 HCB. All rights reserved.
//

#import "ViewController.h"
#import "DeviceAdapter.h"
#import "NSDate+URExtends.h"

static NSArray *appIDs;
static NSString *docPath = @"/Documents/dbs";

@interface AppModel : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *docDirPath;
@end

@implementation AppModel

@end

@interface DocModel : NSObject
@property (nonatomic, strong) AppModel *app;
@property (nonatomic, copy) NSString *docName;
@end

@implementation DocModel

@end

@interface ViewController()<NSTableViewDataSource, DeviceAdapterDelegate>
@property (weak) IBOutlet NSTextField *localPathTF;
@property (weak) IBOutlet NSTextField *deviceLB;
@property (weak) IBOutlet NSTextField *docsPathLB;
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) DeviceAdapter *adapter;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSMutableArray *applicationDicArr;
@property (weak) IBOutlet NSTextField *dateLB;
@property (nonatomic, strong) AFCRootDirectory *root;
@property (weak) IBOutlet NSTextField *processingLB;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.dataSource = self;
    _adapter = [[DeviceAdapter alloc] init];
    _adapter.delegate = self;
    _datas = [NSMutableArray array];
    _applicationDicArr = @[].mutableCopy;
    appIDs = @[@"com.xiwei.yunmanman",@"P01.xiwei.yunmanman",@"P02.xiwei.yunmanman",@"P03.xiwei.yunmanman"];
    _docsPathLB.stringValue = docPath;
    NSDate *yesterday = [[[NSDate date] UR_getNowDateFromatAnDate] yesterday];
    _dateLB.stringValue = [yesterday toStringWithFormat:@"yyyyMMdd"];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

- (void)alertWithTitle:(NSString *)title msg:(NSString *)msg
{
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:title];
    [alert setInformativeText:msg];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:nil];
    return;
}

#pragma mark - Actions

- (IBAction)refreshAction:(NSButton *)sender {
    
}

- (IBAction)exportAction:(id)sender {
    if(!_adapter.isDeviceConnected) {
        [self alertWithTitle:@"提示" msg:@"没有检测到设备"];
        return;
    }
    
    if (!_localPathTF.stringValue.length) {
        NSAlert *alert = [NSAlert new];
        [alert addButtonWithTitle:@"确定"];
        //        [alert addButtonWithTitle:@"取消"];
        [alert setMessageText:@"提示"];
        [alert setInformativeText:@"请填写导出路径"];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
            if(returnCode == NSAlertFirstButtonReturn){
                NSLog(@"确定");
            }
            //            else if(returnCode == NSAlertSecondButtonReturn){
            //                NSLog(@"删除");
            //            }
        }];
        return;
    }
    
    NSString *dirPath = _localPathTF.stringValue;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isdir;
    if (![fileManager fileExistsAtPath:dirPath isDirectory:&isdir]) {
        [self alertWithTitle:@"提示" msg:@"请填写正确的路径"];
        return;
    }
    
    if (!isdir) {
        [self alertWithTitle:@"提示" msg:@"请填写正确的路径"];
        return;
    }
    
    if (!_datas.count) {
        [self alertWithTitle:@"提示" msg:@"没有需要导出的数据"];
        return;
    }
    
    NSButton *btn = sender;
    btn.enabled = NO;
    _processingLB.stringValue = @"导出中...";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL exportResult = YES;
        [_datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DocModel *data = obj;
            NSString *docPath = [data.app.docDirPath stringByAppendingPathComponent:data.docName];
            NSString *localDocPath = [dirPath stringByAppendingPathComponent:data.docName];
            
            if ([fileManager fileExistsAtPath:localDocPath]) {
                [fileManager removeItemAtPath:localDocPath error:nil];
            }
            
            BOOL result = [_root copyRemoteFile:docPath toLocalFile:localDocPath];
            if (!result) {
                exportResult = NO;
                *stop = YES;
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exportResult) {
                _processingLB.stringValue = @"导出成功";
            } else {
                [self alertWithTitle:@"提示" msg:@"导出数据出错"];
                _processingLB.stringValue = @"导出失败";
            }
            
            btn.enabled = YES;
        });
    });
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _datas.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    DocModel *data = _datas[row];
    if ([tableColumn.identifier isEqualToString:@"appName"]) {
        return data.app.appName;
    } else if ([tableColumn.identifier isEqualToString:@"appId"]) {
        return data.app.appId;
    } else if ([tableColumn.identifier isEqualToString:@"doc"]) {
        return data.docName;
    }
    return nil;
}

#pragma mark - DeviceAdapterDelegate
- (void)deviceAdapter:(DeviceAdapter *)DeviceAdapter deviceChanged:(AMDevice *)device {
    if (!device || !device.udid) {
        _root = nil;
        _deviceLB.stringValue = @"设备：";
        [_datas removeAllObjects];
        [_tableView reloadData];
    } else {
        NSString *dateStr = _dateLB.stringValue;
        if (!dateStr.length) {
            return;
        }
        [_datas removeAllObjects];
        _deviceLB.stringValue = [NSString stringWithFormat:@"设备：%@", device.deviceName];
        AFCRootDirectory *root = [device newAFCRootDirectory];
        _root = root;
        //jailbreak device
        if (root) {
            NSMutableArray *appInfos = [NSMutableArray array];
            NSArray *appArr = [device installedApplications];
            [appArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AMApplication *app = obj;
                NSString *appId = app.bundleid;
                if ([appIDs containsObject:appId]) {
                    NSString *containerPath = [app.info objectForKey:@"Container"];
                    AppModel *data = [AppModel new];
                    data.appId = appId;
                    data.appName = app.appname;
                    data.docDirPath = [containerPath stringByAppendingString:docPath];
                    [appInfos addObject:data];
                }
            }];
            
            
            [appInfos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AppModel *app = obj;
                NSArray *arr = [root directoryContents:app.docDirPath];
                [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([(NSString *)obj rangeOfString:dateStr].location != NSNotFound) {
                        DocModel *data = [DocModel new];
                        data.app = app;
                        data.docName = obj;
                        [_datas addObject:data];
                    }
                }];
            }];
            
            [_tableView reloadData];
            return;
        }
        
        //find apps which enable file share
        //        [appIDs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //            NSString *appId = obj;
        //            AFCApplicationDirectory *appDir = [device newAFCApplicationDirectory:appId];
        //            if (appDir) {
        //                [_applicationDicArr addObject:@{appId:appDir}];
        //                NSArray *files = [appDir directoryContents:docPath];
        //                [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //                    if ([[(NSString *)obj pathExtension] isEqualToString:@"db"]) {
        //                        DocModel *data = [DocModel new];
        //                        data.appId = appId;
        //                        data.docName = obj;
        //                        [_datas addObject:data];
        //                    }
        //                }];
        //            }
        //        }];
        //        
        //        [_tableView reloadData];
    }
}
@end
