

#import "MKStoreManager.h"
#import "AppDelegate.h"
#import "GameOver.h"
#import "Global.h"


@implementation MKStoreManager

@synthesize purchasableObjects;
@synthesize storeObserver;

// all your features should be managed one and only by StoreManager

static NSString *featureAdsId = @"com.vincityapps.WAVYLINE.removeads";

BOOL featureAdsPurchased = NO;

static MKStoreManager* _sharedStoreManager; // self



+(BOOL) featureAdsPurchased {
	return featureAdsPurchased;
}

+(MKStoreManager*)sharedManager
{
	NSLog(@"pass sharedManager");
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            [[self alloc] init]; // assignment not done here
			_sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];			
			[_sharedStoreManager requestProductData];
			
			[MKStoreManager loadPurchases];
			_sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
			[[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];
        }
    }
    
    return _sharedStoreManager;
}

#pragma mark Singleton Methods

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (_sharedStoreManager == nil)
        {
            _sharedStoreManager = [super allocWithZone:zone];
            return _sharedStoreManager;  // assignment and return on first allocation
        }
    }

    return nil; //on subsequent allocation attempts return nil
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}


- (void) requestProductData
{
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
								 [NSSet setWithObjects: featureAdsId, nil]]; // add any other product here
	request.delegate = self;
	[request start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[purchasableObjects addObjectsFromArray:response.products];
	// populate your UI Controls here
	for(int i=0;i<[purchasableObjects count];i++)
	{
		
		SKProduct *product = [purchasableObjects objectAtIndex:i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
	}
	
}

- (void) buyFeature:(NSString*) featureId
{
	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:featureId];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hoppy Birds" message:@"You are not authorized to buy from AppStore"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	}
}

- (void) buyFeatureAds
{
	[self buyFeature:featureAdsId];
}


- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
}

-(void) provideContent: (NSString*) productIdentifier
{
	if ([productIdentifier isEqualToString:featureAdsId]) {
		featureAdsPurchased = YES;
        
        if (g_gameOverLayer != nil) {
            [g_gameOverLayer updateMenu];
        }
    }
    
	[MKStoreManager updatePurchases];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"In-App Upgrade" message:@"Successfully Purchased" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

+(void) loadPurchases 
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];	
	featureAdsPurchased = [userDefaults boolForKey:featureAdsId];    
}

+(void) updatePurchases
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	[userDefaults setBool:featureAdsPurchased forKey:featureAdsId];
}

+(void) makePaidVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:YES forKey:featureAdsId];

    [MKStoreManager loadPurchases];
}


-(void)restoreFunc
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
}

@end
