#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
//#define kLatestKivaLoansURL [NSURL URLWithString:@"http://api.kivaws.org/v1/loans/search.json?status=fundraising"] //2

#define kYouTubeMostPop [NSURL URLWithString:@"http://gdata.youtube.com/feeds/api/standardfeeds/most_popular?v=2&alt=json"]
#define backGroundColor [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];

#import "ViewController.h"
#import <objc/runtime.h>


@interface ViewController (){
    NSMutableArray * parseYouTubeData;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    parseYouTubeData = [[NSMutableArray alloc]init];
    
    dispatch_async(kBgQueue, ^{
        
        NSData * data = [NSData dataWithContentsOfURL:kYouTubeMostPop];
        //NSData * data = [NSData dataWithContentsOfFile:@"/Users/nick/Desktop/most_popular.json"];
        
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
        //[self createViewAndApplyData];
    });
}


- (void)createViewAndApplyData {
    
    UIScrollView *scroll = [[UIScrollView alloc]
                            initWithFrame:CGRectMake(0, 20,
                                                     self.view.frame.size.width,
                                                     self.view.frame.size.height)];
    scroll.backgroundColor = [UIColor clearColor];
    scroll.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    scroll.pagingEnabled = true;
	//scroll.bounces = false;
    
    int index = 0;
    
    for (NSDictionary * thisDict in parseYouTubeData){
        
        UIView * thisView = [[UIView alloc]initWithFrame:CGRectMake( index * scroll.frame.size.width, 0 ,
                                                                    scroll.frame.size.width,
                                                                    scroll.frame.size.height)];
        thisView.backgroundColor = [UIColor blueColor];
        
        UIView * titleViewHolder = [[UIView alloc]initWithFrame:CGRectMake(10,10, scroll.frame.size.width - 20, 20)];
        titleViewHolder.backgroundColor = backGroundColor;
        titleViewHolder.layer.cornerRadius = 8;
        titleViewHolder.layer.shadowOffset = CGSizeMake(-5, 10);
        titleViewHolder.layer.shadowRadius = 5;
        titleViewHolder.layer.shadowOpacity = 0.75;
        [thisView addSubview:titleViewHolder];
        
        UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,0, titleViewHolder.frame.size.width - 10, 20)];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = [thisDict objectForKey:@"title"];

        [titleViewHolder addSubview:titleLabel];

        UIImage * img = [UIImage imageWithData:
                        [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:
                        [thisDict objectForKey:@"thumbURL"]]]];
        
        UIImageView * thisImageView = [[UIImageView alloc]initWithImage:img];
        thisImageView.frame = CGRectMake(10, 40,
                                         scroll.frame.size.width - 20,
                                         (scroll.frame.size.width - 20) * 0.75);
        thisImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        thisImageView.layer.cornerRadius = 8;
        thisImageView.layer.shadowOffset = CGSizeMake(-5, 10);
        thisImageView.layer.shadowRadius = 5;
        thisImageView.layer.shadowOpacity = 0.75;
        
        [thisView addSubview:thisImageView];
        
        UIView * mainText = [[UIView alloc]initWithFrame:CGRectMake(10,
                                                                     (scroll.frame.size.width - 20) * 0.75 + 50,
                                                                     scroll.frame.size.width - 20,
                                                                     (scroll.frame.size.height - (scroll.frame.size.width - 20) * 0.75 - 80))];
        mainText.backgroundColor = backGroundColor;
        mainText.layer.masksToBounds = NO;
        mainText.layer.cornerRadius = 8;
        mainText.layer.shadowOffset = CGSizeMake(-5, 10);
        mainText.layer.shadowRadius = 5;
        mainText.layer.shadowOpacity = 0.75;
        [thisView addSubview:mainText];
        
        UILabel * authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,
                                                                         0,
                                                                         mainText.frame.size.width - 5,
                                                                         20)];
        authorLabel.textColor = [UIColor blackColor];
        authorLabel.backgroundColor = [UIColor clearColor];
        authorLabel.text = [thisDict objectForKey:@"authorName"];
        authorLabel.font = [UIFont systemFontOfSize:20];
        [mainText addSubview:authorLabel];
        
        UILabel * viewCount = [[UILabel alloc]initWithFrame:CGRectMake(5,
                                                                         20,
                                                                         mainText.frame.size.width - 5,
                                                                         20)];
        viewCount.textColor = [UIColor blackColor];
        viewCount.backgroundColor = [UIColor clearColor];
        viewCount.text = [@"Viewed: " stringByAppendingString:[thisDict objectForKey:@"viewCount"]];
        viewCount.font = [UIFont systemFontOfSize:12];
        [mainText addSubview:viewCount];
        
        /*UILabel * descriptionText = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                       30,
                                                                       scroll.frame.size.width - 20,
                                                                       100)];
        descriptionText.textColor = [UIColor blackColor];
        descriptionText.backgroundColor = [UIColor clearColor];
        descriptionText.text = [thisDict objectForKey:@"description"];
        [mainText addSubview:descriptionText];*/

        
        //Add Description of Video as Text Scroll
        UITextView * textScroll = [[UITextView alloc]initWithFrame:CGRectMake(0,
                                                                              40,
                                                                              mainText.frame.size.width,
                                                                              mainText.frame.size.height - 80)];
        textScroll.text = [thisDict objectForKey:@"description"];
        textScroll.backgroundColor = backGroundColor;
        textScroll.font = [UIFont systemFontOfSize:14];
        textScroll.editable = NO;
        [mainText addSubview:textScroll];
        
        //Add Link to View Button
        UIButton * linkToVideo = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        linkToVideo.frame = CGRectMake(0,
                                      mainText.frame.size.height - 30,
                                      mainText.frame.size.width,
                                      20);
        [linkToVideo setTitle:@"View Video" forState:UIControlStateNormal];
        [linkToVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [mainText addSubview:linkToVideo];
        //linkToVideo.tag = [thisDict objectForKey:@"link"];
        objc_setAssociatedObject(linkToVideo, @"URLKEY", [thisDict objectForKey:@"link"], OBJC_ASSOCIATION_RETAIN);

        [linkToVideo addTarget:self action:@selector(linkToVideo:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        [scroll addSubview:thisView];
        index = index + 1;
    }
    
    scroll.contentSize = CGSizeMake([parseYouTubeData count] * scroll.frame.size.width,
                                    scroll.frame.size.height );
    [self.view addSubview:scroll];
}



- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    NSDictionary * feed = [json objectForKey:@"feed"];
    
    NSArray * entry = [feed objectForKey:@"entry"];
    
    for (NSDictionary *e in entry) {

        NSMutableDictionary * thisEntry = [[NSMutableDictionary alloc]init];
        
        //set title to this entry dict
        NSString * thisTitle = [[e objectForKey:@"title"] objectForKey:@"$t"];
        [thisEntry setValue:thisTitle forKey:@"title"];
        
        //set thumbnail URL to this entry dict
        NSString * thisThumb = [[[[e objectForKey:@"media$group"]
                          objectForKey:@"media$thumbnail"]
                          objectAtIndex:2]
                          objectForKey:@"url"];
        [thisEntry setValue:thisThumb forKey:@"thumbURL"];
        
        //set author name of this entry
        NSString * thisAuthorName = [[[[e objectForKey:@"author"]
                            objectAtIndex:0]
                            objectForKey:@"name"]
                            objectForKey:@"$t"];
        [thisEntry setValue:thisAuthorName forKey:@"authorName"];
        
        //set view count
        NSString * thisStats = [[e objectForKey:@"yt$statistics"]
                                objectForKey:@"viewCount"];
        [thisEntry setValue:thisStats forKey:@"viewCount"];
        
        //set description of this entry
        NSString * thisDescriptionString = [[[e objectForKey:@"media$group"]
                                            objectForKey:@"media$description"]
                                            objectForKey:@"$t"];
        [thisEntry setValue:thisDescriptionString forKey:@"description"];
        
        //set link for this entry
        NSString * thisLink = [[[e objectForKey:@"link"] objectAtIndex:0] objectForKey:@"href"];
        [thisEntry setValue:thisLink forKey:@"link"];
        
        [parseYouTubeData addObject:thisEntry];
    }
    
    //NSLog(@"My Data:\n%@", [parseYouTubeData description]);
    
    [self createViewAndApplyData];
}

- (IBAction)linkToVideo:(id)sender{
    
    NSString * videoURL = (NSString *)objc_getAssociatedObject(sender, @"URLKEY");
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:videoURL]];
    
    /*UIWebView * thisWebView =[[UIWebView alloc]initWithFrame:self.view.frame];
    [thisWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoURL]]];
    [self.view addSubview:thisWebView];*/
    
    
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"youtube://www.youtube.com/watch?v=fLexgOxsZu0&feature=youtube_gdata"]];
    //NSLog(@"yes");
    
}

@end
