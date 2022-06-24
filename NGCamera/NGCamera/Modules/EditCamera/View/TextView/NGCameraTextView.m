//
//  NGCameraTextView.m
//  NGCamera
//
//  Created by caizhepeng on 2019/11/6.
//  Copyright © 2019 caizhepeng. All rights reserved.
//

#import "NGCameraTextView.h"
#import "MBProgressHUD.h"

#define kColorWidth 27
static const NSInteger kTextMaxLimitNumber = 100;

@interface ColorBoard ()
@property (nonatomic,strong) NSArray *colors;
@property (nonatomic,strong) UIScrollView *colorScrollView;
@end

@implementation ColorBoard
{
    UIButton *_selectedBtn;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createColorBoard];
    }
    return self;
}

- (void)createColorBoard
{
    UIScrollView *colorScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    colorScrollView.contentSize = CGSizeMake((kColorWidth+10) * (self.colors.count-1) + kColorWidth, self.height);
    colorScrollView.showsVerticalScrollIndicator = NO;
    colorScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:colorScrollView];
    self.colorScrollView = colorScrollView;
    
    for (NSInteger i = 0; i < self.colors.count; i++) {
        UIButton *colorBtn = [[UIButton alloc] initWithFrame:CGRectMake((kColorWidth+10) * i , (self.height - kColorWidth)/2, kColorWidth, kColorWidth)];
        colorBtn.layer.cornerRadius = colorBtn.width/2;
        colorBtn.layer.masksToBounds = YES;
        colorBtn.layer.borderWidth = 2;
        colorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        colorBtn.backgroundColor = self.colors[i];
        colorBtn.tag = i;
        [colorBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [colorScrollView addSubview:colorBtn];
        if (colorBtn.tag == 0) {
            colorBtn.selected = YES;
            [self buttonClicked:colorBtn];
        }
    }
}

- (void)buttonClicked:(UIButton *)btn
{
    if (btn != _selectedBtn) {
        _selectedBtn.selected = NO;
        _selectedBtn.layer.borderWidth = 2;
        btn.selected = YES;
        btn.layer.borderWidth = 4;
        if (self.changeColorBlock) {
            self.changeColorBlock(self.colors[btn.tag]);
        }
        _selectedBtn = btn;
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    NSInteger tag = [self.colors indexOfObject:selectedColor];
    for (UIButton *btn in self.colorScrollView.subviews) {
        if (tag == btn.tag) {
            [self buttonClicked:btn];
        }
    }
}

- (NSArray *)colors
{
    if (!_colors) {
        _colors = [NSArray arrayWithObjects:[UIColor whiteColor], [UIColor blackColor], [UIColor brownColor], [UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor darkGrayColor], [UIColor grayColor], [UIColor lightGrayColor], nil];
    }
    return _colors;
}

@end

typedef NS_ENUM (NSInteger, TextButtonTag)
{
    TextButtonTagCancel,
    TextButtonTagFinish
};

@interface NGCameraTextView () <UITextViewDelegate>
@property (nonatomic,strong) ColorBoard *colorBoard;
@property (nonatomic,strong) UILabel *showLabel;
@end

@implementation NGCameraTextView
{
    MBProgressHUD *_HUD;
    dispatch_semaphore_t _textSemaphore;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _textSemaphore = dispatch_semaphore_create(1);
        [self createView];
        [self createColorBoard];
        [self addObserver];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createView
{
    // 毛玻璃效果
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.bounds;
    [self addSubview:effectView];
    
    // cancelBtn
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 45, 45)];
    cancelBtn.tag = TextButtonTagCancel;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    // doneBtn
    UIButton *finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 45-15, 0, 45, 45)];
    finishBtn.tag = TextButtonTagFinish;
    [finishBtn setTitle:@"确定" forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:finishBtn];
    
    // textView
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 45 , self.width, self.height - 45)];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:25];
    textView.textAlignment = NSTextAlignmentLeft;
    textView.returnKeyType = UIKeyboardTypeDefault;
    textView.showsVerticalScrollIndicator = NO;
    textView.showsHorizontalScrollIndicator = NO;
    textView.delegate = self;
    [textView becomeFirstResponder];
    [self addSubview:textView];
    self.textView = textView;
}

- (void)createColorBoard
{
    ColorBoard *colorBoard = [[ColorBoard alloc]initWithFrame:CGRectMake(0, kMainScreenHeigth, kMainScreenWidth, 50)];
    [self addSubview:colorBoard];
    self.colorBoard = colorBoard;
    
    WeakSelf(self);
    colorBoard.changeColorBlock = ^(UIColor * _Nonnull color) {
        StrongSelf(self);
        self.currentColor = color;
        self.textView.textColor = color;
    };
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - 键盘出现
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userinfo = notification.userInfo;
    CGRect keyboardRect  = [[userinfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardAnimationDuration = [[userinfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:keyboardAnimationDuration animations:^{
        self.colorBoard.top = kMainScreenHeigth - keyboardRect.size.height - 50;
    } completion:^(BOOL finished) {}];
}

#pragma mark - 键盘退出
- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userinfo = notification.userInfo;
    CGFloat keyboardAnimationDuration = [[userinfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:keyboardAnimationDuration animations:^{
        self.colorBoard.top = kMainScreenHeigth;
    } completion:^(BOOL finished) {}];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    // 选中范围的标记
    UITextRange *textSelectedRange = [textView markedTextRange];
    // 获取高亮部分
    UITextPosition *textPosition = [textView positionFromPosition:textSelectedRange.start offset:0];
    // 如果在变化中是高亮部分在变, 就不要计算字符了
    if (textSelectedRange && textPosition) {
        return;
    }
    // 文本内容
    NSString *textContentStr = textView.text;
    NSLog(@"text = %@",textView.text);
    NSInteger existTextNumber = textContentStr.length;
    
    if (existTextNumber > kTextMaxLimitNumber) {
        // 截取到最大位置的字符(由于超出截取部分在should时被处理了,所以在这里为了提高效率不在判断)
        NSString *str = [textContentStr substringToIndex:kTextMaxLimitNumber];
        [textView setText:str];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"%@", text);
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < kTextMaxLimitNumber && textView.text.length - offsetRange.length <= kTextMaxLimitNumber) {
            return YES;
        } else
        {
            return NO;
        }
    }
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = kTextMaxLimitNumber - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        return YES;
    } else {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0, MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            } else
            {
                __block NSInteger idx = 0;
                __block NSString  *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                          
                                          NSInteger steplen = substring.length;
                                          if (idx >= rg.length) {
                                              *stop = YES; //取出所需要就break，提高效率
                                              return ;
                                          }
                                          
                                          trimString = [trimString stringByAppendingString:substring];
                                          
                                          idx = idx + steplen;//这里变化了，使用了字串占的长度来作为步长
                                      }];
                
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        [self showMessege];
        return NO;
    }
}

- (void)showMessege
{
    if (dispatch_semaphore_wait(_textSemaphore, DISPATCH_TIME_NOW) != 0) {
        return;
    }
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.showLabel.transform = CGAffineTransformMakeTranslation(0, self.showLabel.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.showLabel.transform = CGAffineTransformIdentity;;
        } completion:^(BOOL finished) {
            dispatch_semaphore_signal(self->_textSemaphore);
        }];
    }];
}

- (void)buttonClicked:(UIButton *)btn
{
    switch (btn.tag) {
        case TextButtonTagCancel: {
            if (self.didCancelBlock) {
                self.didCancelBlock(self);
            }
            break;
        }
        case TextButtonTagFinish: {
            if (self.textView.text.length) {
                NGText *text = [[NGText alloc] init];
                text.attributedText = self.textView.attributedText;
                if (self.didFinishTextBlock) {
                    self.didFinishTextBlock(self, text);
                }
            }
            break;
        }
        default:
            break;
    }
    [self.textView resignFirstResponder];
    [self removeFromSuperview];
}

- (void)setText:(NGText *)text
{
    _text = text;
    if (text.attributedText.length > 0) {
        self.textView.attributedText = text.attributedText;
        self.colorBoard.selectedColor = self.textView.textColor;
    }
}

- (UILabel *)showLabel
{
    if (!_showLabel) {
        _showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -50, self.width, 50)];
        _showLabel.backgroundColor = [UIColor whiteColor];
        _showLabel.text = @"输入字符不能超过100";
        _showLabel.textColor = [UIColor blackColor];
        _showLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.showLabel];
    }
    return _showLabel;
}

@end
