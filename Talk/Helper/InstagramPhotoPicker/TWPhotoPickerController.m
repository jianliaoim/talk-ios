//
//  TWPhotoPickerController.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "TWPhotoPickerController.h"
#import "TWPhotoCollectionViewCell.h"
#import "TWImageScrollView.h"
#import "TWPhotoLoader.h"
#import "UIColor+TBColor.h"
#import "Masonry.h"
#import "UIImage+Orientation.h"

@interface TWPhotoPickerController ()<UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
    CGFloat beginOriginY;
}
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIImageView *maskView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) TWImageScrollView *imageScrollView;

@property (strong, nonatomic) UIView *takePhotoView;

@property (strong, nonatomic) NSArray *allPhotos;
@end

@implementation TWPhotoPickerController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor tb_DarkColor]];
    [self.view addSubview:self.topView];
    [self.view insertSubview:self.collectionView belowSubview:self.topView];
    [self.view addSubview:self.takePhotoView];
    
    [self loadPhotos];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.allPhotos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TWPhotoCollectionViewCell";
    
    TWPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    TWPhoto *photo = [self.allPhotos objectAtIndex:indexPath.row];
    cell.imageView.image = photo.thumbnailImage;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TWPhoto *photo = [self.allPhotos objectAtIndex:indexPath.row];
    [self.imageScrollView displayImage:photo.originalImage];
//    if (self.topView.frame.origin.y != 0) {
//        [self tapGestureAction:nil];
//    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    if (velocity.y >= 2.0 && self.topView.frame.origin.y == 0) {
//        [self tapGestureAction:nil];
//    }
}



#pragma mark - event response

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cropAction {
    if (self.cropBlock) {
        self.cropBlock(self.imageScrollView.capture);
    }
    //[self backAction];
}

- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
//    switch (panGesture.state)
//    {
//        case UIGestureRecognizerStateEnded:
//        case UIGestureRecognizerStateCancelled:
//        case UIGestureRecognizerStateFailed:
//        {
//            CGRect topFrame = self.topView.frame;
//            CGFloat endOriginY = self.topView.frame.origin.y;
//            if (endOriginY > beginOriginY) {
//                topFrame.origin.y = (endOriginY - beginOriginY) >= 20 ? 0 : -(CGRectGetHeight(self.topView.bounds)-20-44);
//            } else if (endOriginY < beginOriginY) {
//                topFrame.origin.y = (beginOriginY - endOriginY) >= 20 ? -(CGRectGetHeight(self.topView.bounds)-20-44) : 0;
//            }
//            
//            CGRect collectionFrame = self.collectionView.frame;
//            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
//            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
//            [UIView animateWithDuration:.3f animations:^{
//                self.topView.frame = topFrame;
//                self.collectionView.frame = collectionFrame;
//            }];
//            break;
//        }
//        case UIGestureRecognizerStateBegan:
//        {
//            beginOriginY = self.topView.frame.origin.y;
//            break;
//        }
//        case UIGestureRecognizerStateChanged:
//        {
//            CGPoint translation = [panGesture translationInView:self.view];
//            CGRect topFrame = self.topView.frame;
//            topFrame.origin.y = translation.y + beginOriginY;
//            
//            CGRect collectionFrame = self.collectionView.frame;
//            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
//            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
//            
//            if (topFrame.origin.y <= 0 && (topFrame.origin.y >= -(CGRectGetHeight(self.topView.bounds)-20-44))) {
//                self.topView.frame = topFrame;
//                self.collectionView.frame = collectionFrame;
//            }
//            
//            break;
//        }
//        default:
//            break;
//    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    CGRect topFrame = self.topView.frame;
    topFrame.origin.y = topFrame.origin.y == 0 ? -(CGRectGetHeight(self.topView.bounds)-20-44) : 0;
    
    CGRect collectionFrame = self.collectionView.frame;
    collectionFrame.origin.y = CGRectGetMaxY(topFrame);
    collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
    [UIView animateWithDuration:.3f animations:^{
        self.topView.frame = topFrame;
        self.collectionView.frame = collectionFrame;
    }];
}

- (void)TakePhoto:(UIButton *)sender {
    UIImagePickerController * controlerPicker = [[UIImagePickerController alloc]init];
    controlerPicker.navigationBar.tintColor = [UIColor whiteColor];
    controlerPicker.delegate = self;
    controlerPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:controlerPicker animated:YES completion:nil];
}

#pragma mark - private methods

- (void)loadPhotos {
    [TWPhotoLoader loadAllPhotos:^(NSArray *photos, NSError *error) {
        if (!error) {
            self.allPhotos = [NSArray arrayWithArray:photos];
            if (self.allPhotos.count) {
                TWPhoto *firstPhoto = [self.allPhotos objectAtIndex:0];
                [self.imageScrollView displayImage:firstPhoto.originalImage];
            }
            [self.collectionView reloadData];
        } else {
            NSLog(@"Load Photos Error: %@", error);
        }
    }];
    
}



#pragma mark - getters & setters

- (UIView *)topView {
    if (_topView == nil) {
        CGFloat handleHeight = 44.0f;
        //CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)+handleHeight*2);
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), handleHeight + 20);
        self.topView = [[UIView alloc] initWithFrame:rect];
        self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.topView.backgroundColor = [UIColor clearColor];
        self.topView.clipsToBounds = YES;
        
        rect = CGRectMake(0, 0, CGRectGetWidth(self.topView.bounds), handleHeight + 20);
        UIView *navView = [[UIView alloc] initWithFrame:rect];//26 29 33
        navView.backgroundColor = [UIColor tb_DarkColor];
        [self.topView addSubview:navView];
        
        rect = CGRectMake(0, 0, 60, CGRectGetHeight(navView.bounds) + 20);
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = rect;
        [backBtn setImage:[UIImage imageNamed:@"Close"]
                 forState:UIControlStateNormal];
        //[backBtn setTitle:@"取消" forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:backBtn];
        
        rect = CGRectMake((CGRectGetWidth(navView.bounds)-200)/2, 0, 200, CGRectGetHeight(navView.bounds) + 20);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
        titleLabel.text = NSLocalizedString(@"Share Image", @"Share Image");
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [navView addSubview:titleLabel];
        
        rect = CGRectMake(CGRectGetWidth(navView.bounds)-60, 0, 60, CGRectGetHeight(navView.bounds) + 20);
        UIButton *cropBtn = [[UIButton alloc] initWithFrame:rect];
        [cropBtn setImage:[UIImage imageNamed:@"Next"]
                 forState:UIControlStateNormal];
        //[cropBtn setTitle:@"OK" forState:UIControlStateNormal];
        [cropBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [cropBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [cropBtn addTarget:self action:@selector(cropAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:cropBtn];
        
//        rect = CGRectMake(0, CGRectGetHeight(self.topView.bounds)-handleHeight, CGRectGetWidth(self.topView.bounds), handleHeight);
//        UIView *dragView = [[UIView alloc] initWithFrame:rect];
//        dragView.backgroundColor = navView.backgroundColor;
//        dragView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//        [self.topView addSubview:dragView];
        
//        UIImage *img = [UIImage imageNamed:@"TWPhotoPicker.bundle/cameraroll-picker-grip.png"];
//        rect = CGRectMake((CGRectGetWidth(dragView.bounds)-img.size.width)/2, (CGRectGetHeight(dragView.bounds)-img.size.height)/2, img.size.width, img.size.height);
//        UIImageView *gripView = [[UIImageView alloc] initWithFrame:rect];
//        gripView.image = img;
//        [dragView addSubview:gripView];
//        
//        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
//        [dragView addGestureRecognizer:panGesture];
//        
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
//        [dragView addGestureRecognizer:tapGesture];
//        
//        [tapGesture requireGestureRecognizerToFail:panGesture];
//        
//        rect = CGRectMake(0, handleHeight, CGRectGetWidth(self.topView.bounds), CGRectGetHeight(self.topView.bounds)-handleHeight*2);
        self.imageScrollView = [[TWImageScrollView alloc] init];
//        [self.topView addSubview:self.imageScrollView];
//        [self.topView sendSubviewToBack:self.imageScrollView];
//        
//        self.maskView = [[UIImageView alloc] initWithFrame:rect];
//        
//        self.maskView.image = [UIImage imageNamed:@"TWPhotoPicker.bundle/straighten-grid.png"];
//        [self.topView insertSubview:self.maskView aboveSubview:self.imageScrollView];
    }
    return _topView;
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        CGFloat colum = 4.0, spacing = 3.0;
        CGFloat value = floorf((CGRectGetWidth(self.view.bounds) - (colum - 1) * spacing) / colum);
        
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize                     = CGSizeMake(value, value);
        layout.sectionInset                 = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumInteritemSpacing      = spacing;
        layout.minimumLineSpacing           = spacing;
        
        CGRect rect = CGRectMake(0, CGRectGetMaxY(self.topView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-CGRectGetHeight(self.topView.bounds)-114);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[TWPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"TWPhotoCollectionViewCell"];
    }
    return _collectionView;
}

- (UIView *)takePhotoView {
    if (_takePhotoView == nil) {
        CGRect rect = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 114, CGRectGetWidth(self.view.bounds), 114);
        _takePhotoView = [[UIView alloc] initWithFrame:rect];
        _takePhotoView.backgroundColor = [UIColor tb_DarkColor];
        UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        takePhotoButton.backgroundColor = [UIColor colorWithRed:57/255.f green:60/255.f blue:64/255.f alpha:0.5];
        [takePhotoButton setTitle:NSLocalizedString(@"Take a Photo", @"Take photo") forState:UIControlStateNormal];
        takePhotoButton.tintColor = [UIColor whiteColor];
        takePhotoButton.layer.masksToBounds = YES;
        takePhotoButton.layer.cornerRadius = 5;
        [takePhotoButton addTarget:self action:@selector(TakePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [_takePhotoView addSubview:takePhotoButton];
        UIEdgeInsets padding = UIEdgeInsetsMake(30, 25, 30, 25);
        [takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_takePhotoView.mas_top).with.offset(padding.top); //with is an optional semantic filler
            make.left.equalTo(_takePhotoView.mas_left).with.offset(padding.left);
            make.bottom.equalTo(_takePhotoView.mas_bottom).with.offset(-padding.bottom);
            make.right.equalTo(_takePhotoView.mas_right).with.offset(-padding.right);
        }];
        [takePhotoButton layoutIfNeeded];

    }
    return _takePhotoView;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    //[picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *takePhoto = [UIImage fixOrientation:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [self.imageScrollView displayImage:takePhoto];
    if (self.cropBlock) {
        self.cropBlock(self.imageScrollView.capture);
    }
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    //User presentingViewController to dismiss this controller, avoid pop to root -- DW
//    [picker.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
