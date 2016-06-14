//
//  MultiPickerViewController.m
//  operateCamera
//
//  Created by 李根 on 16/6/13.
//  Copyright © 2016年 ligen. All rights reserved.
//

#import "MultiPickerViewController.h"
#import "CTAssetsPickerController.h"

@interface MultiPickerViewController ()<CTAssetsPickerControllerDelegate>

@end

@implementation MultiPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor purpleColor];
    
    UIButton *selectMultiImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:selectMultiImageBtn];
    selectMultiImageBtn.frame = CGRectMake(100, 450, 100, 30);
    [selectMultiImageBtn setTitle:@"选择多张图片" forState:UIControlStateNormal];
    [selectMultiImageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectMultiImageBtn addTarget:self action:@selector(selectMultiImage:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:backBtn];
    backBtn.frame = CGRectMake(100, 500, 100, 30);
    [backBtn setTitle:@"back" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)selectMultiImage:(id)sender {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            return ;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //  弹出图片选择界面
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            //  隐藏空相册
            picker.showsEmptyAlbums = NO;
            //  显示图片索引
            picker.showsSelectionIndex = YES;
            picker.assetCollectionSubtypes = @[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary), @(PHAssetCollectionSubtypeAlbumRegular)];
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset {
    NSInteger max = 9;
    if (picker.selectedAssets.count < max) return YES;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"be careful" message:[NSString stringWithFormat:@"最多选择张图片%ld", max] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:(UIAlertActionStyleDefault) handler:nil]];
    //  这里一定要用picker, 不能使用self, 因为当前显示在上面的控制器是picker, 不是self
    [picker presentViewController:alert animated:YES completion:nil];
    
    return NO;
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray<PHAsset *> *)assets {
    //  关闭图片选择界面
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //  选择图片时的配置项
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    //  显示图片
    for (NSInteger i = 0; i < assets.count; i++) {
        PHAsset *asset = assets[i];
        CGSize size = CGSizeMake(asset.pixelWidth / [UIScreen mainScreen].scale, asset.pixelHeight / [UIScreen mainScreen].scale);
        
        //  请求图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:(PHImageContentModeDefault) options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            //  添加图片控件
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = result;
            [self.view addSubview:imageView];
            
            imageView.frame = CGRectMake((i % 3) * (100 + 10), (i / 3) * (100 + 10), 100, 100);
        }];
        
    }
}

- (void)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
