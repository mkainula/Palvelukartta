//
//  ViewController.h
//  Palvelukartta
//
//  Created by Matias Kainulainen on 28/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapPoint.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    
    CLLocationCoordinate2D currentCentre;
    int currenDist;
    BOOL firstLaunch;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;


@end
