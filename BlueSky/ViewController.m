//
//  ViewController.m
//  BlueSky
//
//  Created by B03023 on 2014/07/15.
//  Copyright (c) 2014年 easyjp. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong) CBCentralManager* myCentralManager;
@property (strong) CBPeripheralManager* myPeripheralManager;
@property (strong) CBMutableCharacteristic* myCharacteristic;
@property (strong) CBMutableService* myService;
@property (strong) CBPeripheral * targetPeripheral;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.myCentralManager =
    //[[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];
    
}

- (IBAction)startPeripheral:(id)sender
{
    self.myPeripheralManager =
    [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    CBUUID *myServiceUUID =
    [CBUUID UUIDWithString:@"71DA3FD1-7E10-41C1-B16F-4430B506CDE7"];
    CBUUID *myCharacteristicUUID = [CBUUID UUIDWithString:@"7D910446-D78C-4ADA-80F1-F744F55F307A"];
    
    NSData* myValue = [@"Hello, World" dataUsingEncoding:NSUTF8StringEncoding];
    
    self.myCharacteristic =
    [[CBMutableCharacteristic alloc] initWithType:myCharacteristicUUID
                                       properties:CBCharacteristicPropertyRead
                                            value:myValue permissions:CBAttributePermissionsReadable];
    
    self.myService = [[CBMutableService alloc] initWithType:myServiceUUID primary:YES];
    self.myService.characteristics = @[self.myCharacteristic];
    
    [self.myPeripheralManager addService:self.myService];
    [self.myPeripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey :
                                                      @[self.myService.UUID], CBAdvertisementDataLocalNameKey : @"Hello Service" }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    
    NSLog(@"Discovered <<%@>>, %@", peripheral.name, advertisementData);
    
    if ([peripheral.name isEqualToString:@"iPhone"]) {
        [self.myCentralManager connectPeripheral:peripheral options:nil];
        self.targetPeripheral = peripheral;
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"state: %d", central.state);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"state: %d", peripheral.state);
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"Peripheral connected");
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error {
    
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    NSData *data = characteristic.value;
    // parse the data as needed
    NSString* value = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    NSLog(@"didUpdateValue: %@", value);
}

@end
