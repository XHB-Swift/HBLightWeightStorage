# HBLightWeightStorage
基于NSUserDefault以及Keychain的轻量存储封装，不适宜使用在庞大数据存储场景
## Usage
``` Objective-C
#import "HBLightWeightStorage.h"
```
## Example
NSUserDefault存储数据，数据会使用Global Queue异步存储到NSUserDefault当中
``` Objective-C
[HBLightWeightStorage setUserDefaultValue:@"value" withKey:@"key"];
```
NSUserDefault读取数据，读取数据时传入Class进行类型校验，不符合类型时返回nil
``` Objective-C
id value = [HBLightWeightStorage userDefaultValueWithKey:@"key" valueClass:[NSString class]];
```
生成Keychain查询配置，传nil默认为：@"com.xhb.keychain.id"
``` Objective-C
NSDictionary *query = [HBLightWeightStorage keychainQueryWithServiceName:@"user"];
```
Keychain同步存储数据
``` Objective-C
[HBLightWeightStorage setKeychainValue:@"value" withKeyQueries:query];
```
Keychain同步读数据
``` Objective-C
id value = [HBLightWeightStorage keychainValueWithKeyQueries:query valueClass:[NSString class]];
```
使用内存存放数据
``` Objective-C
HBLightWeightStorage *storage = [HBLightWeightStorage lightWeightStorageWithType:0]; //0表示从NSUserDefault加载数据，1表示从Keychain加载数据
```
往内存写入数据
``` Objective-C
[storage setValue:@"value" forKey:@"key"];
```
从内存读取数据
``` Objective-C
id value = [storage valueForKey:@"key" valueClass:[NSString class]];
```
将内存数据本地持久化
``` Objective-C
[storage persistentToLocalWithType:0];
```
## Author
1021580211@qq.com



