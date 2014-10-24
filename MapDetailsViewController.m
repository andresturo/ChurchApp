//
//  MapDetailsViewController.m
//  MapViewApplication
//
//  Created by Daniel Cardona on 8/28/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "MapDetailsViewController.h"
#import "PageContentsViewController.h"

@interface MapDetailsViewController ()
<UIActionSheetDelegate, UIPageViewControllerDataSource,UIPageViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionSheetbarButton;
//PageViewController Properties
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong,nonatomic)IBOutlet UIPageControl* pageControl;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

//ScrollView
@property (strong,nonatomic)IBOutlet UIScrollView* scrollView;

@end

@implementation MapDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    _titleLabel.text = _detailsTitle;
    self.navigationController.navigationBar.topItem.title = _detailsTitle;
    _subtitleLabel.text = _detailsSubtitle;
    _linkLabel.text = _detailLink;
    
    // Create the data model for Paging
    _pageTitles = @[@"Alabanza", @"Campamentos", @"Escuela de Musica", @"Grupo de Jovenes"];
    _pageImages = @[@"Alabanza.jpg", @"Campamentos.jpg", @"EscuelaMusica.jpg", @"GrupoJovenes.jpg"];
    
    //Create a page a view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    PageContentsViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, _pageViewController.view.frame.size.width, _pageViewController.view.frame.size.height - 150);
    
    
    
    [self addChildViewController:_pageViewController];
    //[self.view addSubview:_pageViewController.view];
    [self.scrollView addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    //Set UIPageControl
    
    [self.pageControl setNumberOfPages:self.pageTitles.count];
    //[self.view bringSubviewToFront:self.pageControl];
    [self.scrollView bringSubviewToFront:self.pageControl];
    
    //Disable gesture on navigation for going back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    //Configure ScrollView
    
    [self.scrollView setContentSize:CGSizeMake(320, 700)];
  

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - IBActions

- (IBAction)openRedilWebsite:(id)sender {
    //NSString* webSiteLink = [NSString stringWithFormat:@"http://%@",_detailLink];
    UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:@"Select an Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open Link in Safari",@"Call", nil];
    
    [actionSheet showFromBarButtonItem:_actionSheetbarButton animated:YES];
    
}
#pragma mark - UIActionSheetDelegate Protocol Methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSURL* url;
    
    switch (buttonIndex) {
        case 0:
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_detailLink]];
            break;
        case 1:
            url = [NSURL URLWithString:@"telprompt://123-4567-890"];
            [[UIApplication  sharedApplication] openURL:url];

            break;
        default:
            break;
    }
}
#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentsViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentsViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}
#pragma mark - UIPageViewControllerDelegate
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
   
    if (!completed) {
        return;
    }
    
    PageContentsViewController* currentViewController = (PageContentsViewController*)[self.pageViewController.viewControllers lastObject];
    NSInteger indexForCurrentViewController = currentViewController.pageIndex;
    [self.pageControl setCurrentPage:indexForCurrentViewController];
    
    
}

#pragma mark - UIPageControl
//This UIPageViewControllerDataSource method will make a UIPageControl appear automatically
//But a fixed position in screen

/*
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}
 
 */


#pragma mark - PageViewController Helper 
- (PageContentsViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentsViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    
    return pageContentViewController;
}
@end
