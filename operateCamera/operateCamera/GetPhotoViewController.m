//
//  GetPhotoViewController.m
//  operateCamera
//
//  Created by 李根 on 16/6/13.
//  Copyright © 2016年 ligen. All rights reserved.
//

#import "GetPhotoViewController.h"

@interface GetPhotoViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UIImageView *photoView;

@end

@implementation GetPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    _photoView = [[UIImageView alloc] init];
    [self.view addSubview:_photoView];
    _photoView.backgroundColor = [UIColor lightGrayColor];
    _photoView.center = self.view.center;
    
    UIButton *findphotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:findphotoBtn];
    findphotoBtn.frame = CGRectMake(100, 450, 100, 30);
    [findphotoBtn setTitle:@"寻找照片" forState:UIControlStateNormal];
    [findphotoBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [findphotoBtn addTarget:self action:@selector(pickPhotos:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:backBtn];
    backBtn.frame = CGRectMake(100, 500, 100, 30);
    [backBtn setTitle:@"back" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pickPhotos:(id)sender {
    //  弹出 alertVIew来让用户选择
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    [alertController addAction:[UIAlertAction actionWithTitle:@"open camera" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self opencamera];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"get photo from library" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self openAlbum];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

//  用相机拍一张照片
- (void)opencamera {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    /**
     *  UIImagePickerControllerSourceType
     *
     *  SourceType pickerController 的类型
     *  UIImagePickerControllerSourceTypePhotoLibrary,     从 所有 相册中选择
     *  UIImagePickerControllerSourceTypeCamera,           弹出照相机
     *  UIImagePickerControllerSourceTypeSavedPhotosAlbum  从 moment 相册中选择
     */
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

//  从相册中获取
- (void)openAlbum {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image;
    image = info[UIImagePickerControllerOriginalImage];
    _photoView.image = image;
    _photoView.frame = CGRectMake(50, 10, 300, 300 * (image.size.height / image.size.width));
    [picker dismissViewControllerAnimated:YES completion:nil];
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
