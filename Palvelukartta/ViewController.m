//
//  ViewController.m
//  Palvelukartta
//
//  Created by Matias Kainulainen on 28/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.mapView.delegate = self;     
    [self.mapView setShowsUserLocation:YES];
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    firstLaunch=YES;

}

-(void) fetchJSON
{
    // Get the places from Hel.fi API
    NSString *url = [NSString stringWithFormat:@"http://www.hel.fi/palvelukarttaws/rest/v2/unit/?lat=%.05f&lon=%.05f&distance=%@", currentCentre.latitude, currentCentre.longitude, [NSString stringWithFormat:@"%i", currenDist]];
    NSLog(@"url %@", url);
    NSURL *requestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: requestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
    // parse JSON
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData 
                          options:kNilOptions 
                          error:&error];

    NSLog(@"JSON Data: %@", json);
    
    // Cast the dictionary to an array
    NSArray* places = (NSArray *)json; 
    
    //Write out the data to the console.

    // NSLog(@"Places: %@", places);
    
    //Plot the data in the places array onto the map with the plotPostions method.
    [self addMapPositions:places];
    
    
}

- (void)addMapPositions:(NSArray *)data
{
    // Remove existing
    for (id<MKAnnotation> annotation in mapView.annotations) 
    {
        if ([annotation isKindOfClass:[MapPoint class]]) 
        {
            [mapView removeAnnotation:annotation];
        }
    }

    for (int i=0; i<[data count]; i++)
    {
        // Retrieve name & address from JSON
        NSDictionary* place = [data objectAtIndex:i];
        
        NSString *name=[place objectForKey:@"name_fi"];
        NSString *address=[place objectForKey:@"street_address_fi"];
        
        // Create Coordinate
        CLLocationCoordinate2D coordinate;
        
        coordinate.latitude=[[place objectForKey:@"latitude"] doubleValue];
        coordinate.longitude=[[place objectForKey:@"longitude"] doubleValue];
        
        // Create MapPoint
        MapPoint *placeObject = [[MapPoint alloc] initWithName:name address:address coordinate:coordinate];

        // Add a place

        [mapView addAnnotation:placeObject];
    }
}

- (IBAction)toolBarButtonPress:(id)sender {
    UIBarButtonItem *button = (UIBarButtonItem *)sender; 
    NSString *buttonTitle = [button.title lowercaseString];
    [self fetchJSON];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - MKMapViewDelegate methods.
    
    
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{    
    
    //Zoom back to the user location after adding a new set of annotations.
    
    //Get the center point of the visible map.
    CLLocationCoordinate2D centre = [mv centerCoordinate];
    
    MKCoordinateRegion region;
    
    //If this is the first launch of the app then set the center point of the map to the user's location.
    if (firstLaunch) {
        region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate,1000,1000);
        firstLaunch=NO;
    }else {
        // Current center point
        region = MKCoordinateRegionMakeWithDistance(centre,currenDist,currenDist);
    }
    
    //Set the visible region of the map.
    [mv setRegion:region animated:YES];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    //Define our reuse indentifier.
    static NSString *identifier = @"MapPoint";   
    
    
    if ([annotation isKindOfClass:[MapPoint class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        
        return annotationView;
    }
    
    return nil;    
}
    
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    //Get the east and west points on the map so we calculate the distance (zoom level) of the current map view.
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    //Set our current distance instance variable.
    currenDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    //Set our current centre point on the map instance variable.
    currentCentre = self.mapView.centerCoordinate;
}    

@end
