//
//  MACameraController.m
//
//  Created by YURI_JOU on 15-4-2.
//

#import "MACameraController.h"

#import "MACameraView.h"
#import "MACameraManager.h"
#import "MACameraManager+AuthorizationExtra.h"
#import "MACameraManager+FlashModeExtra.h"
#import "MACameraManager+FocusIntrestPointExtra.h"

#import "MABundleManager.h"

#import "UIView+Extra.h"
#import "UIColor+HexExtra.h"
#import "UIControl+Extra.h"

#import <Masonry.h>
#import <POP.h>

#define metamacro_concat(A, B) A ## B
#define weakify(VAR) \
autoreleasepool {} \
__weak __typeof__(VAR) metamacro_concat(VAR, _weak_) = (VAR)
#define strongify(VAR) \
autoreleasepool {} \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong __typeof__(VAR) VAR = metamacro_concat(VAR, _weak_)\
_Pragma("clang diagnostic pop")

#define folderNames @"Cache_folders"



@interface MACameraController()

@property (nonatomic, strong)MACameraManager *cameraManager;

@property (nonatomic, strong)UIView *headerPanel;
@property (nonatomic, strong)UIView *footerPanel;
@property (nonatomic, strong)MACameraView *cameraPanel;

@property (nonatomic, strong)UIButton *flashButton;
@property (nonatomic, strong)UIButton *switchButton;

@property (nonatomic, strong)UIButton *cancelButton;
@property (nonatomic, strong)UIButton *snapButton;
@property (nonatomic, strong)UIImageView *snapDecoratedOuter;
@property (nonatomic, strong)UIButton *albumButton;
@property (nonatomic, strong)UIView *albumPlaceHolder;
@property (nonatomic, strong)UIImageView *albumPreview;

@end

@implementation MACameraController

- (void)viewDidLoad{
  [super viewDidLoad];
  [self ma_layoutViews];
  [self ma_setupAppearance];
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                              action:@selector(handleTap:)];
  [self.cameraPanel addGestureRecognizer:tapGesture];
  self.edgesForExtendedLayout = UIRectEdgeBottom;
}

- (void)handleTap:(UIGestureRecognizer *)gesture{
  CGPoint point = [gesture locationInView:self.cameraPanel];
  [self.cameraManager focusOnPoint:point];
}

- (void)ma_layoutViews{
  
  //layout header panel
  [self.view addSubview:self.headerPanel];
  [self.headerPanel addSubview:self.flashButton];
  [self.headerPanel addSubview:self.switchButton];
  
  [self.headerPanel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.and.right.equalTo(self.view);
    make.height.mas_equalTo(45.0f);
  }];
  
  [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(44.0f, 44.0f));
    make.centerY.equalTo(self.headerPanel);
    make.left.mas_equalTo(25.0f);
  }];
  
  [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(44.0f, 44.0f));
    make.centerY.equalTo(self.headerPanel);
    make.right.mas_equalTo(-25.0f);
  }];
  
  //layout footer panel
  [self.view addSubview:self.footerPanel];

  [self.footerPanel addSubview:self.snapDecoratedOuter];
  [self.footerPanel addSubview:self.snapButton];
  [self.footerPanel addSubview:self.cancelButton];
  [self.footerPanel addSubview:self.albumButton];
  
  [self.footerPanel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.bottom.and.right.equalTo(self.view);
    make.height.mas_equalTo(200);
  }];
  
  [self.snapButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(50.0f, 50.0f));
    make.center.equalTo(self.footerPanel);
  }];
  
  [self.snapDecoratedOuter mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(66.0f, 66.0f));
    make.center.equalTo(self.footerPanel);
  }];
  
  [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(25.0f);
    make.top.bottom.equalTo(self.footerPanel);
    make.right.equalTo(self.snapDecoratedOuter.mas_left);
  }];
  
  //layout camera panel
  [self.view addSubview:self.cameraPanel];
  [self.cameraPanel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.headerPanel.mas_bottom);
    make.bottom.equalTo(self.footerPanel.mas_top);
    make.left.and.right.equalTo(self.view);
  }];
  
  //decorate album
  
  [self.footerPanel addSubview:self.albumPlaceHolder];
  [self.footerPanel addSubview:self.albumButton];
  
  [self.albumPlaceHolder mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(45.0f, 45.0f));
    make.centerY.equalTo(self.footerPanel);
    make.right.mas_equalTo(-25.0f);
  }];
  
  [self.albumButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.mas_equalTo(-25.0f);
    make.left.equalTo(self.snapButton.mas_right);
    make.top.bottom.equalTo(self.footerPanel);
  }];
  
}

- (void)ma_setupAppearance{
  [self ma_coverPreviewLayer:self.cameraManager.cameraLayer];
  [self.cameraPanel setCameraLayer:self.cameraManager.cameraLayer];
}

- (void)ma_coverPreviewLayer:(CALayer *)layer{
  CGFloat height = CGRectGetHeight(layer.frame);
  CGFloat width = CGRectGetWidth(layer.frame);
  UIView *top = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height / 2.0f)];
  top.backgroundColor = [UIColor blackColor];
  UIView *bottom = [[UIView alloc]initWithFrame:CGRectMake(0, height / 2.0f, width, height)];
  bottom.backgroundColor = [UIColor blackColor];
  [layer addSublayer:top.layer];
  [layer addSublayer:bottom.layer];
  CGPoint point = top.layer.position;
  point.y -= height / 2.0f;
  CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
  basicAnimation.toValue = [NSValue valueWithCGPoint:point];
  basicAnimation.duration = 0.15f;
  basicAnimation.beginTime =  CACurrentMediaTime() + 0.45;
  basicAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  basicAnimation.removedOnCompletion=NO;
  basicAnimation.fillMode=kCAFillModeForwards;
  [top.layer addAnimation:basicAnimation forKey:@"top"];
  CGPoint bottomPoint = bottom.layer.position;
  bottomPoint.y += height / 2.0f;
  basicAnimation.toValue = [NSValue valueWithCGPoint:bottomPoint];
  [bottom.layer addAnimation:basicAnimation forKey:@"bottom"];

}

#pragma mark - accessor
- (MACameraManager *)cameraManager{
  return [MACameraManager manager];
}

- (UIView *)headerPanel{
  if (!_headerPanel ) {
    UIView *panel = [[UIView alloc]initWithFrame:CGRectZero];
    panel.backgroundColor = [UIColor colorWithHex:0x141414];
    _headerPanel = panel;
  }
  return _headerPanel;
}

- (UIView *)footerPanel{
  if (!_footerPanel) {
    UIView *panel = [[UIView alloc]initWithFrame:CGRectZero];
    panel.backgroundColor = [UIColor colorWithHex:0x141414];
    _footerPanel = panel;
  }
  return _footerPanel;
}

- (UIButton *)flashButton{
  if (!_flashButton) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"camera_flashlight_open"];
    [button setBackgroundImage:image
                      forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    @weakify(button);
    [button addActionBlock:^(id sender) {
      @strongify(button);
      if (self.cameraManager.cameraType == MACameraTypePhoto) {
        [self.cameraManager switchFlashMode:^(AVCaptureFlashMode flashMode) {
          NSString *imageName = @"";
          switch (flashMode) {
            case AVCaptureFlashModeAuto:
              imageName = @"camera_flashlight_auto";
              break;
            case AVCaptureFlashModeOff:
              imageName = @"camera_flashlight_disable";
              break;
            case AVCaptureFlashModeOn:
              imageName = @"camera_flashlight_open";
              break;
            default:
              break;
          }
          UIImage *place = [UIImage imageNamed:imageName];
          [button setBackgroundImage:place
                            forState:UIControlStateNormal];
        }];
      }
    } forControlEvents:UIControlEventTouchUpInside];
    _flashButton = button;
  }
  return _flashButton;
}

- (UIButton *)switchButton{
  if (!_switchButton) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"camera_overturn"];
    [button setBackgroundImage:image
                      forState:UIControlStateNormal];
    [button addActionBlock:^(id sender) {
      [self.cameraManager switchCamera:^{
        
      }];
    } forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    _switchButton = button;
  }
  return _switchButton;
}

- (UIButton *)snapButton{
  if (!_snapButton) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *image = [[UIImage imageNamed:@"camera_snap_start"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    static BOOL flag = YES;
//    @weakify(button);
//    [button addActionBlock:^(id sender) {
//      @strongify(button);
//      if (flag) {
//        [self.cameraManager resumeRecord];
//        [button setTintColor:[UIColor redColor]];
//        flag = NO;
//      }else{
//        [self.cameraManager pauseRecord];
//        [button setTintColor:[UIColor whiteColor]];
//        flag = YES;
//      }
//    } forControlEvents:UIControlEventTouchUpInside];
    @weakify(self);
    [button addActionBlock:^(id sender) {
      @strongify(self);
      [self.cameraManager snap:^(UIImage *image) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.image = image;
        imageView.frame = self.cameraPanel.bounds;
//        [self.cameraPanel addSubview:imageView];
//        [self.cameraPanel bringSubviewToFront:imageView];
        
        [self.albumPreview removeFromSuperview];
        UIImageView *preview = [[UIImageView alloc]initWithImage:image];
        preview.contentMode = UIViewContentModeScaleAspectFill;
        preview.frame = CGRectMake(0, 0, 45.0f, 45.0f);
        preview.layer.cornerRadius = 2.0f;
        preview.layer.masksToBounds = YES;
        [self.albumPlaceHolder addSubview:preview];
        POPSpringAnimation *zoomin = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        zoomin.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.0, 0.0)];
        zoomin.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)];
        
        zoomin.springBounciness = 3.0;
        zoomin.springSpeed = 8.0;
        [preview.layer pop_addAnimation:zoomin forKey:@"zoom_in"];
        
        POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
        opacityAnimation.fromValue = @0.0;
        opacityAnimation.toValue = @1;
        opacityAnimation.beginTime = CACurrentMediaTime();
        opacityAnimation.duration = 1.0;
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [preview.layer pop_addAnimation:opacityAnimation forKey:@"opacity"];
        
        self.albumPreview = preview;
        
      }];
    } forControlEvents:UIControlEventTouchUpInside];
    _snapButton = button;
  }
  return _snapButton;
}

- (UIButton *)cancelButton{
  if (!_cancelButton) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setAlignmentToLeft];
    [button addActionBlock:^(id sender) {
      if (self.cancelBlock) {
        self.cancelBlock(self);
      }
    } forControlEvents:UIControlEventTouchUpInside];
    _cancelButton = button;
  }
  return _cancelButton;
}

- (UIButton *)albumButton{
  if (!_albumButton) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    _albumButton = button;
  }
  return _albumButton;
}

- (UIImageView *)snapDecoratedOuter{
  if (!_snapDecoratedOuter) {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    UIImage *outerImage = [UIImage imageNamed:@"camera_snap_normal_outer"];
    
    imageView.image = outerImage;
    imageView.backgroundColor = [UIColor clearColor];
    _snapDecoratedOuter = imageView;
  }
  return _snapDecoratedOuter;
}

- (MACameraView *)cameraPanel{
  if (!_cameraPanel) {
    MACameraView *panel = [[MACameraView alloc]initWithFrame:CGRectZero];
    panel.backgroundColor = [UIColor clearColor];
    _cameraPanel = panel;
  }
  return _cameraPanel;
}

- (UIView *)albumPlaceHolder{
  if (!_albumPlaceHolder) {
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    view.backgroundColor =[UIColor clearColor];
    _albumPlaceHolder = view;
  }
  return _albumPlaceHolder;
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

@end
