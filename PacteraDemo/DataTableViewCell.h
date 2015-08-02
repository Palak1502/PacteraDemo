//
//  DataTableViewCell.h
//  PacteraDemo
//


#import <UIKit/UIKit.h>

@interface DataTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel * titleLabel;
@property (nonatomic, strong) IBOutlet UIView * view;
@property (nonatomic, strong) IBOutlet UILabel * descLabel;
@property (nonatomic, strong) IBOutlet UIImageView * imageViewCell;

@end
