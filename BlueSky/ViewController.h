//
//  ViewController.h
//  BlueSky
//
//  Created by B03023 on 2014/07/15.
//  Copyright (c) 2014年 easyjp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate>

@end
