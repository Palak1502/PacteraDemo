//
//  ViewController.m
//  PacteraDemo

#import "ViewController.h"
#import "CountryRecord.h"
#import "ServiceClient.h"
#import "ParseJsonData.h"
#import "IconDownloader.h"
#import "DataTableViewCell.h"
#import "PDConstants.h"


@interface ViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataRecord;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;
- (IBAction)refreshData:(id)sender;

@end


@implementation ViewController

// -------------------------------------------------------------------------------
//	viewDidLoad
// -------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    [_indicatorView startAnimating];
    [self loadDataForTabelView:^{
        [_indicatorView stopAnimating];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_indicatorView stopAnimating];
        [self showDialog:PDErrorDomain message:error.localizedDescription];
    }];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
}

// -------------------------------------------------------------------------------
//	terminateAllDownloads
// -------------------------------------------------------------------------------
- (void)terminateAllDownloads
{
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];

    [self.imageDownloadsInProgress removeAllObjects];
}

// -------------------------------------------------------------------------------
//	dealloc
//  If this view controller is going away, we need to cancel all outstanding downloads.
// -------------------------------------------------------------------------------
- (void)dealloc
{
    // terminate all pending download connections
    [self terminateAllDownloads];
}

// -------------------------------------------------------------------------------
//	didReceiveMemoryWarning
// -------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // terminate all pending download connections
    [self terminateAllDownloads];
}

// -------------------------------------------------------------------------------
//	tableView:numberOfRowsInSection:
//  Customize the number of rows in the table view.
// -------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = self.dataRecord.count;
    // if there's no data yet, return enough rows to fill the screen
    if (count == 0) {
        return _dataRecord.count;
    }
    return count;
}

// -------------------------------------------------------------------------------
//	tableView:cellForRowAtIndexPath:
// -------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger nodeCount = _dataRecord.count;
     DataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

        // Leave cells empty if there's no data yet
        if (nodeCount > 0) {
            // Set up the cell representing the app
            CountryRecord *countryRecord = (_dataRecord)[indexPath.row];
            cell.titleLabel.text = countryRecord.title;
            cell.descLabel.text = countryRecord.desc;
            // Only load cached images; defer new downloads until scrolling ends
            if (!countryRecord.eventIcon) {
                if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
                    [self startIconDownload:countryRecord forIndexPath:indexPath];
                }
                // if a download is deferred or in progress, return a placeholder image
                cell.imageViewCell.image = [UIImage imageNamed:@"Placeholder.png"];
            } else {
                cell.imageViewCell.image = countryRecord.eventIcon;
            }
        }

    return cell;
}

// -------------------------------------------------------------------------------
//	heightForRowAtIndexPath:
// -------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static DataTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    });
    CountryRecord *countryRecord = (_dataRecord)[indexPath.row];
    sizingCell.titleLabel.text = countryRecord.title;
    sizingCell.descLabel.text = countryRecord.desc;
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    CGFloat height = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height*2;
}

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(CountryRecord *)countryRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.countryRecord = countryRecord;
        [iconDownloader setCompletionHandler:^{
            DataTableViewCell *cell = (DataTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

            // Display the newly loaded image
            cell.imageViewCell.image = countryRecord.eventIcon;

            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];

        }];
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
            [iconDownloader startDownload];
        }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if (_dataRecord.count > 0)
        {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
            {
            CountryRecord *countryRecord = (_dataRecord)[indexPath.row];

            if (!countryRecord.eventIcon)
                // Avoid the app icon download if the app already has an icon
                {
                [self startIconDownload:countryRecord forIndexPath:indexPath];
                }
            }
        }
}


// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
     }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}
// -------------------------------------------------------------------------------
//	loadDataForTabelView:(void (^)())success
//  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//  load data for represent the tableview after fetched data.
//
- (void)loadDataForTabelView:(void (^)())success
failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [ServiceClient getDetailsOfCanada:^(AFHTTPRequestOperation *operation, NSDictionary *json) {
        ParseJsonData *parserJsonData = [[ParseJsonData alloc]init];
        _dataRecord = [parserJsonData initWithJsonParser:json].receiverData;
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation,error);
    }];

}

// -------------------------------------------------------------------------------
//	(IBAction)refreshData:(id)sender
//  Refresh data when user pull down the view.
// -------------------------------------------------------------------------------
- (IBAction)refreshData:(id)sender {
    [self loadDataForTabelView:^{
        [self.tableView reloadData];
        [sender endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showDialog:PDErrorDomain message:error.localizedDescription];
        [sender endRefreshing];
    }];
}

// -------------------------------------------------------------------------------
//	showDialog:(NSString*)title  message:(NSString*)message
//  Display message dialog.
// -------------------------------------------------------------------------------
- (void)showDialog:(NSString*)title  message:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:OK
                                          otherButtonTitles:nil];
    [alert show];
}
@end
