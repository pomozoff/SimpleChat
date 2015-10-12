//
//  LocationDataSource.m
//  SimpleChat
//
//  Created by Антон on 13.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import MapKit;

#import "LocationDataSource.h"

@implementation LocationDataSource

- (void)makeImageLocationForChatMessage:(id <ChatMessage>)chatMessage forSize:(CGSize)size withCompletion:(FetchImageCompletionHandler)handler {
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(chatMessage.latitude, chatMessage.longitude);
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = location;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.015f, 0.015f);
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);

    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = region;
    options.scale = [[UIScreen mainScreen] scale];
    options.size = size;
 
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
    dispatch_queue_t executeOnBackground = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [snapshotter startWithQueue:executeOnBackground completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        
        UIImage *image = snapshot.image;
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        {
            [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
            
            CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
            CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
            if (CGRectContainsPoint(rect, point)) {
                point.x = point.x + pin.centerOffset.x - (pin.bounds.size.width / 2.0f);
                point.y = point.y + pin.centerOffset.y - (pin.bounds.size.height / 2.0f);
                [pin.image drawAtPoint:point];
            }
            
            UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
            chatMessage.image = compositeImage;
        }
        UIGraphicsEndImageContext();
        
        handler(chatMessage.image, error);
    }];
}

@end
