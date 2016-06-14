//
//  ViewController.m
//  operateCamera
//
//  Created by 李根 on 16/6/13.
//  Copyright © 2016年 ligen. All rights reserved.
//

#import "ViewController.h"
#import "GetPhotoViewController.h"
#import "MultiPickerViewController.h"

#import <Photos/Photos.h>

@interface ViewController ()
{
    UIImageView *imageview;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    imageview = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 200, 200)];
    [self.view addSubview:imageview];
    imageview.image = [UIImage imageNamed:@"avater"];
    
    UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:oneBtn];
    oneBtn.frame = CGRectMake(60, 300, 200, 30);
    [oneBtn setTitle:@"第三方选择多张照片" forState:UIControlStateNormal];
    [oneBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    UIButton *twoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:twoBtn];
    twoBtn.frame = CGRectMake(60, 360, 200, 30);
    [twoBtn setTitle:@"从相册中获取图片" forState:UIControlStateNormal];
    [twoBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    UIButton *threeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:threeBtn];
    threeBtn.frame = CGRectMake(60, 420, 200, 30);
    [threeBtn setTitle:@"保存图片到自定义相册中" forState:UIControlStateNormal];
    [threeBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    //  增加点击事件
    [oneBtn addTarget:self action:@selector(pickMultiPhotos:) forControlEvents:UIControlEventTouchUpInside];
    
    [twoBtn addTarget:self action:@selector(gotoGetPhotoVC:) forControlEvents:UIControlEventTouchUpInside];
    
    [threeBtn addTarget:self action:@selector(saveImageToAlbum:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)pickMultiPhotos:(id)sender {
    MultiPickerViewController *multiPickerVC = [[MultiPickerViewController alloc] init];
    [self presentViewController:multiPickerVC animated:YES completion:nil];
}

- (void)gotoGetPhotoVC:(id)sender {
    GetPhotoViewController *getPhotoVC = [[GetPhotoViewController alloc] init];
    [self presentViewController:getPhotoVC animated:YES completion:nil];
}

- (void)saveImageToAlbum:(id)sender {
    //  获取当前app对photo的访问权限
    PHAuthorizationStatus OldStatus = [PHPhotoLibrary authorizationStatus];
    
    //  检查访问权限, 当前app对相册的检查权限
    /**
     * PHAuthorizationStatus
     * PHAuthorizationStatusNotDetermined = 0, 用户还未决定
     * PHAuthorizationStatusRestricted,        系统限制，不允许访问相册 比如家长模式
     * PHAuthorizationStatusDenied,            用户不允许访问
     * PHAuthorizationStatusAuthorized         用户可以访问
     * 如果之前已经选择过，会直接执行 block，并且把以前的状态传给你
     * 如果之前没有选择过，会弹框，在用户选择后调用 block 并且把用户的选择告诉你
     * 注意：该方法的 block 在子线程中运行 因此，弹框什么的需要回到主线程执行
     */
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                //            [self cSaveToCameraRoll];
                //            [self photoSaveToCameraRoll];
                //            [self fetchCameraRoll];
                //            [self createCustomAssetCollection];
                //            [self createdAsset];
                //            [self saveImageToCustomAlbum2];
                [self saveImageToCustomAlbum2];
            } else if (OldStatus != PHAuthorizationStatusNotDetermined && status == PHAuthorizationStatusDenied) {
                //  用户上一次选择了不允许访问, 且这次又点击了保存, 这里可以适当提醒用户允许访问相册
                UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"您还未授权操作相册" message:nil delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
                [aler show];
            }
            
        });
    }];
    
}

#pragma mark    - 将图片保存到自定义相册中, 第二种写法, 直接保存placeholder到自定义相册
- (void)saveImageToCustomAlbum2 {
    //  将图片保存到相册胶卷
    NSError *error = nil;
    __block PHObjectPlaceholder *placeholder = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        placeholder = [PHAssetChangeRequest creationRequestForAssetFromImage:imageview.image].placeholderForCreatedAsset;
    } error:&error];
    if (error) {
        NSLog(@"保存失败");
    }
    
    //  获取自定义相册
    PHAssetCollection *createdCollection = [self createCustomAssetCollection];
    
    //  将图片保存到自定义相册
    /**
     * 必须通过中间类，PHAssetCollectionChangeRequest 来完成
     * 步骤：1.首先根据相册获取 PHAssetCollectionChangeRequest 对象
     *      2.然后根据 PHAssetCollectionChangeRequest 来添加图片
     * 这一步的实现有两个思路：1.通过上面的占位 asset 的标识来获取 相机胶卷中的 asset
     *                       然后，将 asset 添加到 request 中
     *                     2.直接将 占位 asset 添加到 request 中去也是可行的
     */
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:@[placeholder] atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    if (error) {
        NSLog(@"保存失败");
    } else {
        NSLog(@"保存成功");
    }
    
}

#pragma mark    - 将图片保存到自定义相册中, 较规范的写法
- (void)saveImageToCustomAlbum1 {
    //  获取保存到相机胶卷中的图片
    PHAsset *createdAsset = [self createdAssets].firstObject;
    if (createdAsset == nil) {
        NSLog(@"保存图片失败");
    }
    //  获取自定义相册
    PHAssetCollection *createdCollection = [self createCustomAssetCollection];
    if (createdCollection == nil) {
        NSLog(@"创建相册失败");
    }
    
    NSError *error = nil;
    //  保存图片到自定义相册
    /**
     * 必须通过中间类，PHAssetCollectionChangeRequest 来完成
     * 步骤：1.首先根据相册获取 PHAssetCollectionChangeRequest 对象
     *      2.然后根据 PHAssetCollectionChangeRequest 来添加图片
     * 这一步的实现有两个思路：1.通过上面的占位 asset 的标识来获取 相机胶卷中的 asset
     *                       然后，将 asset 添加到 request 中
     *                     2.直接将 占位 asset 添加到 request 中去也是可行的
     */
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
//        [request addAssets:@[placeholder]];
        [request insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    if (error) {
        NSLog(@"保存失败");
    } else {
        NSLog(@"保存成功");
    }
}

#pragma mark    - 获取保存到 相机胶卷 的图片
- (PHFetchResult<PHAsset *> *)createdAssets {
    //  将图片保存到相册胶卷
    NSError *error = nil;
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromImage:imageview.image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    if (error) {
        return nil;
    }
    
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PHAssetCollection *)createCustomAssetCollection {
    //  获取app名称
    NSString *title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    
    NSError *error = nil;
    
    //  查找app中是否有改相册, 如果已经有了, 就不在创建
    /**
     *     参数一 枚举：
     *     PHAssetCollectionTypeAlbum      = 1, 用户自定义相册
     *     PHAssetCollectionTypeSmartAlbum = 2, 系统相册
     *     PHAssetCollectionTypeMoment     = 3, 按时间排序的相册
     *
     *     参数二 枚举：PHAssetCollectionSubtype
     *     参数二的枚举有非常多，但是可以根据识别单词来找出我们想要的。
     *     比如：PHAssetCollectionTypeSmartAlbum 系统相册 PHAssetCollectionSubtypeSmartAlbumUserLibrary 用户相册 就能获取到相机胶卷
     *     PHAssetCollectionSubtypeAlbumRegular 常规相册
     */
    PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:(PHAssetCollectionTypeAlbum) subtype:(PHAssetCollectionSubtypeAlbumRegular) options:nil];
    for (PHAssetCollection *collection in result) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    
    //  来这里说明相册不存在, 需要创建相册
    __block NSString *createdCustomAssetCollectionIdentifier = nil;
    //  创建和app名称一样的相册
    /**
     *  注意, 这个方法只是告诉 photos 我要创建一个相册, 并没有真的创建, 必须等到
     *  performChangesAndWait block执行完毕后才会真的创建相册
     */
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        /**
         *  collectionChangeRequest 即使我们告诉 photos 要创建相册, 但是此时还没有创建相册
         *  , 因此现在我们并不能拿到所创建的相册, 我们的需求是: 将图片保存到自定义的相册中, 因此
         *  , 我们需要拿到自己创建的相册, 从头文件可以看出, collectionChangeRequest中有一个
         *  占位相册, placeholderForCreatedAssetCollection, 这个占位相册虽然不是我们所创建
         *  的, 但是其identifier和我们所创建的自定义相册的identifier是相同的. 所以想要拿到我们
         *   自定义的相册, 必须保存这个identifier, 等photos app 创建完成后通过identifier来拿
         *  到我们自定义的相册
         */
        createdCustomAssetCollectionIdentifier = collectionChangeRequest.placeholderForCreatedAssetCollection.localIdentifier;
        
    } error:&error];
    
    //  block结束这里, 相册也创建完毕了
    if (error) {
        return nil;
    }
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCustomAssetCollectionIdentifier] options:nil].firstObject;
    
    
}





























@end
