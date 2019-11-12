//
//  HBLightWeightStorage.h
//  HBLightWeightStorage
//
//  Created by 谢鸿标 on 2019/11/12.
//  Copyright © 2019 谢鸿标. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBLightWeightStorage : NSObject

#pragma mark - 内存读写

+ (instancetype)lightWeightStorageWithType:(NSUInteger)type;

- (void)setValue:(id _Nullable)value forKey:(NSString *)key;

- (id _Nullable)valueForKey:(NSString *)key valueClass:(Class)cls;

/// 数据持久化
/// @param type 持久化类型，0：NSUserDefault；1：Keychain
- (void)persistentToLocalWithType:(NSUInteger)type;

#pragma mark - NSUserDefault

+ (void)setUserDefaultValue:(id _Nullable)value withKey:(NSString *)key;

+ (id _Nullable)userDefaultValueWithKey:(NSString *)key valueClass:(Class)cls;

#pragma mark - Keychain

+ (NSDictionary *)keychainQueryWithServiceName:(NSString *_Nullable)serviceName;

+ (void)setKeychainValue:(id _Nullable)value withKeyQueries:(NSDictionary *)keyQueries;

+ (id _Nullable)keychainValueWithKeyQueries:(NSDictionary *)keyQueries valueClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
