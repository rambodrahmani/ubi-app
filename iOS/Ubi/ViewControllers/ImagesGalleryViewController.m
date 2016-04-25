//
//  ImagesGalleryViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 05/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "ImagesGalleryViewController.h"

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

@interface ImagesGalleryViewController ()

@end

@implementation ImagesGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	fotoCaricate = [[NSMutableArray alloc] init];
	
	[self setTitle:_selectedUbiPlace.place_name];
	
	[_collectionView setContentInset:UIEdgeInsetsMake(8, 8, 8, 8)];
	
	[self loadPlacePhotos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ShowImageviewView"]) {
		UINavigationController *destinationNavController = (UINavigationController *)segue.destinationViewController;
		ImageviewViewController *destinationViewController = (ImageviewViewController *)destinationNavController.viewControllers[0];
		destinationViewController.selectedImageURL = (NSURL *)sender;
	}
}

- (void)loadPlacePhotos
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	NSDictionary *params = @{@"place_id": _selectedUbiPlace.db_id};
	
	[manager POST:[NSString stringWithFormat:@"%@/read_place_photos.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSError *error;
			NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
			
			if (!error) {
				for (NSDictionary *tempDictionary in jsonArray) {
					[fotoCaricate addObject:[NSURL URLWithString:[tempDictionary objectForKey:@"photo_url"]]];
				}
			}
			else
			{
				[self showErrorMessage:error.description];
			}
			
			[_collectionView reloadData];
		});
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self showErrorMessage:error.description];
	}];
}

#pragma mark - UICollectionView datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [fotoCaricate count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	GalleryPhotoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"galleryImageCell" forIndexPath:indexPath];
	
	[cell.imgViewFoto sd_setImageWithURL:[fotoCaricate objectAtIndex:indexPath.row] placeholderImage:[UIImage imageNamed:@""]];
	[cell.imgViewFoto setContentMode:UIViewContentModeScaleAspectFill];
	cell.imgViewFoto.clipsToBounds = YES;
	
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	CGSize newCellSize = _collectionView.frame.size;
	newCellSize.height = 146;
	newCellSize.width = 146;
	
	return newCellSize;
}

#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSURL * selectedPhoto = [fotoCaricate objectAtIndex:indexPath.row];
	
	[self performSegueWithIdentifier:@"ShowImageviewView" sender:selectedPhoto];
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

@end
