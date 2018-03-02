//
//  RootViewController.m
//  PhotoPicturesHomeWork
//
//  Created by zouming MacBook  pro on 15/7/13.
//  Copyright (c) 2015年 邹明. All rights reserved.
//

#import "RootViewController.h"


#define kScrollViewImageViewOfTag 200

@interface RootViewController ()<UIScrollViewDelegate,UIAlertViewDelegate>
@property (nonatomic,retain)UIScrollView *scrollPictures;//存放图集的大scrollView
@property (nonatomic,retain)UIScrollView *scrollViewImageView;//存放图片的小scrollView
@property (nonatomic,retain)NSMutableArray *picturesArray;//存放图片对象的数组

@property (nonatomic,retain)UILabel *numberOfLabel;//图片右上角的显示当前图片页数


//设置底部的大scrollview
-(void)_setupScollviewPictures;
//创建存放图片的小scrollviewImageView
-(void)_setupScollviewImageView;

@end

@implementation RootViewController


//存放图片对象的数组
- (NSMutableArray *)picturesArray {
    if (_picturesArray == nil) {
        self.picturesArray = [NSMutableArray array];
    }
    return _picturesArray;
}
//当前照片页数
-(UILabel *)numberOfLabel{
    if (_numberOfLabel == 0) {
        self.numberOfLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 20, 50, 30)];
        _numberOfLabel.textColor = [UIColor redColor];
        _numberOfLabel.backgroundColor = [UIColor clearColor];
        
    }
    return _numberOfLabel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //将图片添加到存放图片的数组中
    for (int i = 0; i < 4; i++) {
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d",i + 1] ofType:@"jpeg"]];
        [self.picturesArray addObject:image];
    }
    
    [self _setupScollviewPictures];
    [self _setupScollviewImageView];
    
    //提前显示第一张图片上的数字
    self.numberOfLabel.text = [NSString stringWithFormat:@"1/%ld",(unsigned long)self.picturesArray.count];
    [self.view addSubview:self.numberOfLabel];
    self.view.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
}
//设置底部大的scrollview
-(void)_setupScollviewPictures{
    //设置scrollview的内容contentsize
    self.scrollPictures = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    self.scrollPictures.contentSize = CGSizeMake(self.picturesArray.count * self.view.bounds.size.width, self.view.bounds.size.height);
    //允许整屏翻动
    self.scrollPictures.pagingEnabled = YES;
    //设置代理对象
    self.scrollPictures.delegate = self;
    [self.view addSubview:self.scrollPictures];
}
//创建存放图片的小scrollviewImageView
-(void)_setupScollviewImageView{
    for (int i = 0; i < self.picturesArray.count; i++) {
        self.scrollViewImageView = [[UIScrollView alloc]initWithFrame:CGRectMake(i * self.view.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
        //设置内容大小
        self.scrollViewImageView.contentSize = self.view.bounds.size;
        self.scrollViewImageView.zoomScale = 1.0;
        //设置scrollPictures的最大最小缩放比例
        self.scrollViewImageView.maximumZoomScale = 3.0;
        self.scrollViewImageView.minimumZoomScale = 1.0;
        self.scrollViewImageView.bouncesZoom = YES;
        UIImageView *imageView = [[UIImageView alloc]init];
        //取出数组里的图片给imageView显示
        imageView.image = [self.picturesArray objectAtIndex:i];
        //设置scrollViewImageView上的imageView,注意取imageView.image.size.height和imageView.image.size.width可以利用比例调节适配,所以可以通过.imgae属性得到图片，然后使用它的高和宽按比例来显示
        imageView.frame = CGRectMake(0, 0, self.scrollViewImageView.frame.size.width, self.scrollViewImageView.frame.size.width * imageView.image.size.height / imageView.image.size.width);
        //注意此时一定是把大的scrollview的center赋给图片的center，而不是把小的scrollView的center赋给它
        imageView.center = self.scrollPictures.center;
        //设置代理对象
        self.scrollViewImageView.delegate = self;
        self.scrollViewImageView.tag = kScrollViewImageViewOfTag + i;
        [self.scrollViewImageView addSubview:imageView];
        [self.scrollPictures addSubview:self.scrollViewImageView];
        //设置双击操作
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleClickAction:)];
        tapGesture.numberOfTapsRequired = 2;
        [self.scrollViewImageView addGestureRecognizer:tapGesture];

        ////添加长按手势,保存图片到手机中
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleOfLongPressActio:)];
        [self.scrollViewImageView addGestureRecognizer:longPress];
    }
}
//双击手势的响应方法
-(void)handleDoubleClickAction:(UIGestureRecognizer *)sender{
    //取到手势上的view视图对象,也就是小的scrollview
    UIScrollView *scrollView = (UIScrollView *)sender.view;
    //如果当前图片的大小是最小的缩放比例  则让它放到最大比例     反之，则放到最小比例
    if (scrollView.zoomScale == scrollView.minimumZoomScale) {
        [scrollView setZoomScale:scrollView.maximumZoomScale animated:YES];
    }else{
        [scrollView setZoomScale:1.0 animated:YES];
    }
}

//长按手势响应方法
- (void)handleOfLongPressActio:(UIGestureRecognizer *)sender
{
    //安全起见，判断sender是否是长按手势类型
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        //当手势开始时
        if (sender.state == UIGestureRecognizerStateBegan) {
            //得到手势上的视图
            UIScrollView *scrollView = (UIScrollView*)sender.view;
            //得到小的scrollview上的子视图 也就是图片视图
            UIImageView *imageView = (UIImageView *)[scrollView.subviews firstObject];
            //得到图片  判断图片是否存在
            if (imageView.image) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存照片" message:@"是否保存照片?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            }
        }
    }
}
//处理保存图片操作
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //下标为1的就是确定，此时把图片保存到手机中，
    if (buttonIndex == 1) {
        //得到底部大scrollview的偏移量
        NSInteger index =( self.scrollPictures.contentOffset.x )/ self.scrollPictures.bounds.size.width;
        //得到小的scrollview
        UIScrollView *scrollview = (UIScrollView *)[self.scrollPictures viewWithTag:kScrollViewImageViewOfTag + index];
        //得到图片
        UIImageView *imageView = (UIImageView *)[[scrollview subviews]firstObject];
        //保存图片到手机中
        UIImageWriteToSavedPhotosAlbum(imageView.image, nil, nil, NULL);
    }
}

//给图片添加缩放方法，允许缩放
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    //因为大scrollview和小的scrollview都设置了代理  所以，先判断为小scrollview后，再允许缩放
    if (scrollView != self.scrollPictures) {
        return scrollView.subviews.firstObject;//图片视图
    }
    return nil;
}
//图片缩放完成时触发的方法   图片缩放完成时，让图片在中间显示，而且尺寸比例正确，不失真
//代理方法
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //因为已经只允许小的scrollView可以缩放，所以，不用判断此时的参数scrollView，肯定是小的scrollView
    UIImageView *_imageView = [scrollView.subviews firstObject];//得到图片
    CGSize boundsSize = scrollView.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    //如果图片的宽度比高度大
    if (frameToCenter.size.width < boundsSize.width){
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }else{
        frameToCenter.origin.x = 0;
    }
    //如果图片的高度比宽度大
    if (frameToCenter.size.height < boundsSize.height){
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }else{
        frameToCenter.origin.y = 0;
    }
    _imageView.frame = frameToCenter;
}
//完成拖拽的方法
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //如果scrollView为大的scrollView时，则响应拖拽完成的方法，
    if (scrollView == self.scrollPictures) {
        //得到整屏偏移量的个数
        NSInteger index = (self.scrollPictures.contentOffset.x )/ self.scrollPictures.bounds.size.width;
        //添加
        //便历scrollView上的子视图，得到小的uiscrollview类型的视图
        for (id tempScrollImageView in scrollView.subviews) {
            if ([tempScrollImageView isKindOfClass:[UIScrollView class]]) {
                //如果此时的视图不等于拖拽之后的视图，则把之前的视图缩放成原来的大小
                if (tempScrollImageView != (UIScrollView *)[self.scrollPictures viewWithTag:kScrollViewImageViewOfTag + index]) {
                    [tempScrollImageView setZoomScale:1.0 animated:YES];
                    //当拖拽结束且此图片视图不是此前视图时，,当前是第几张图片
                    self.numberOfLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)(index + 1),(unsigned long)self.picturesArray.count];
                }
            }
        }
    }
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
