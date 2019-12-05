//
//  HBLightWeightStorage.m
//  HBLightWeightStorage
//
//  Created by 谢鸿标 on 2019/11/12.
//  Copyright © 2019 谢鸿标. All rights reserved.
//

#import "HBLightWeightStorage.h"

@interface HBLightWeightStorage ()

@property (nonatomic, strong) NSMutableDictionary *memoryCache;

@end

@implementation HBLightWeightStorage

+ (instancetype)lightWeightStorageWithType:(NSUInteger)type {
    return [[HBLightWeightStorage alloc] init];
}

- (instancetype)initWithType:(NSUInteger)type {
    if (self = [super init]) {
        //根据类型加载本地数据到内存
        switch (type) {
            case 0:
            {
                _memoryCache = [HBLightWeightStorage userDefaultValueWithKey:@"com.xhb.memory.cache" valueClass:[NSMutableDictionary class]];
                break;
            }
            case 1:
            {
                _memoryCache = [HBLightWeightStorage keychainValueWithKeyQueries:[HBLightWeightStorage keychainQueryWithServiceName:nil] valueClass:[NSMutableDictionary class]];
                break;
            }
            default:
                break;
        }
        //本地数据不存在，使用空容器
        if (!_memoryCache) {
            _memoryCache = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

- (id _Nullable)valueForKey:(NSString *)key valueClass:(Class)cls {
    id value = nil;
    if (key) {
        value = [_memoryCache objectForKey:key];
    }
    return (cls && [value isKindOfClass:cls]) ? value : nil;;
}

- (void)setValue:(id _Nullable)value forKey:(NSString *)key {
    if (key && value) {
        [_memoryCache setObject:value forKey:key];
    }
}

- (void)persistentToLocalWithType:(NSUInteger)type {
    switch (type) {
        case 0:
        {
            [HBLightWeightStorage setUserDefaultValue:self.memoryCache withKey:@"com.xhb.memory.cache"];
            break;
        }
        case 1:
        {
            [HBLightWeightStorage setKeychainValue:self.memoryCache withKeyQueries:[HBLightWeightStorage keychainQueryWithServiceName:nil]];
            break;
        }
        default:
            break;
    }
}

+ (void)setUserDefaultValue:(id _Nullable)value withKey:(NSString *)key {
    if (key && value) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSData *objectData = [self keyedArchiverWithValue:value];
            if (objectData) {
                [userDefault setObject:objectData forKey:key];
                [userDefault synchronize]; //存储值立即变成持久对象
            }
        });
    }
}

+ (id _Nullable)userDefaultValueWithKey:(NSString *)key valueClass:(nonnull Class)cls {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    id persistentObject = nil;
    if (key && cls) {
        NSData *objectData = [userDefault objectForKey:key];
        persistentObject = [self keyedUnarchiverWithData:objectData valueClass:cls];
    }
    return persistentObject;
}

+ (NSDictionary *)keychainQueryWithServiceName:(NSString *_Nullable)serviceName {
    NSString *kServiceName = serviceName ?: @"com.xhb.keychain.id";
    return [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer NSString *)kSecClassGenericPassword,
            (__bridge_transfer NSString *)kSecClass,
            (__bridge_transfer NSString *)kSecAttrAccessibleAfterFirstUnlock,
            (__bridge_transfer NSString *)kSecAttrAccessible,
            kServiceName,
            (__bridge_transfer NSString *)kSecAttrService,
            kServiceName,
            (__bridge_transfer NSString *)kSecAttrAccount,
            nil];
}

+ (void)setKeychainValue:(id _Nullable)value withKeyQueries:(NSDictionary *)keyQueries {
    if (value && keyQueries) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *archivedData = [self keyedArchiverWithValue:value];
            if (archivedData) {
                NSMutableDictionary *mKeyQueries = [NSMutableDictionary dictionaryWithDictionary:keyQueries];
                [mKeyQueries setObject:archivedData forKey:(__bridge id)kSecValueData];
                SecItemAdd((__bridge CFMutableDictionaryRef)mKeyQueries, NULL);
            }
        });
    }
}

+ (id _Nullable)keychainValueWithKeyQueries:(NSDictionary *)keyQueries valueClass:(nonnull Class)cls {
    id value = nil;
    if (keyQueries && cls) {
        id kReturnData = (__bridge_transfer id)kSecReturnData;
        id kMatchLimit = (__bridge_transfer id)kSecMatchLimit;
        NSMutableDictionary *mKeyQueries = nil;
        if (keyQueries[kReturnData] == nil) {
            mKeyQueries = [NSMutableDictionary dictionaryWithDictionary:keyQueries];
            mKeyQueries[kReturnData] = (__bridge_transfer id)kCFBooleanTrue;
        }
        if (keyQueries[kMatchLimit] == nil) {
            if (!mKeyQueries) {
                mKeyQueries = [NSMutableDictionary dictionaryWithDictionary:keyQueries];
            }
            mKeyQueries[kMatchLimit] = (__bridge_transfer id)kSecMatchLimitOne;
        }
        CFMutableDictionaryRef query = (__bridge_retained CFMutableDictionaryRef)mKeyQueries;
        CFTypeRef result = NULL;
        OSStatus status = SecItemCopyMatching(query, &result);
        if (status == noErr) {
            NSData *archivedData = (__bridge_transfer NSData *)result;
            value = [self keyedUnarchiverWithData:archivedData valueClass:cls];
        }
        if (query) {
            CFRelease(query);
            query = NULL;
        }
    }
    return value;
}

#pragma mark - 私有方法，解归档Data

+ (NSData *_Nullable)keyedArchiverWithValue:(id _Nullable)value {
    NSData *valueData = nil;
    Class keyedArhiverClass = [NSKeyedArchiver class];
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    BOOL isBiggerThan11 = (systemVersion >= 11.0);
    NSString *archiverMethod = isBiggerThan11 ? @"archivedDataWithRootObject:requiringSecureCoding:error:":@"archivedDataWithRootObject:";
    SEL archiverSel = NSSelectorFromString(archiverMethod);
    if (archiverSel != NULL && [NSKeyedArchiver respondsToSelector:archiverSel]) {
        IMP archiverImp = [NSKeyedArchiver methodForSelector:archiverSel];
        if (archiverImp != NULL) {
            [NSKeyedArchiver setClassName:NSStringFromClass([value class]) forClass:[value class]];
            if (isBiggerThan11) {
                NSData *(*func)(id,SEL,id,BOOL,NSError **) = (void *)archiverImp;
                NSError *error = nil;
                valueData = func(keyedArhiverClass, archiverSel, value, YES, &error);
                if (error) {
                    NSLog(@"%s, error = %@", __func__, error);
                }
            }else {
                NSData *(*func)(id,SEL,id) = (void *)archiverImp;
                valueData = func(keyedArhiverClass, archiverSel, value);
            }
        }
    }
    return valueData;
}

+ (id _Nullable)keyedUnarchiverWithData:(NSData *_Nullable)data valueClass:(Class)cls {
    id value = nil;
    if (data) {
        Class keyedUnarchiverClass = [NSKeyedUnarchiver class];
        float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        BOOL isBiggerThan11 = systemVersion >= 11.0;
        NSString *archiverMethod = isBiggerThan11 ? @"unarchivedObjectOfClasses:fromData:error:":@"unarchiveObjectWithData:";
        SEL archiverSel = NSSelectorFromString(archiverMethod);
        if (archiverSel != NULL && [NSKeyedUnarchiver respondsToSelector:archiverSel]) {
            IMP archiverImp = [NSKeyedUnarchiver methodForSelector:archiverSel];
            if (archiverImp != NULL) {
                [NSKeyedUnarchiver setClass:cls forClassName:NSStringFromClass(cls)];
                if (isBiggerThan11) {
                    id(*func)(id,SEL,NSSet<Class> *,NSData *,NSError **) = (void *)archiverImp;
                    NSError *error = nil;
                    NSSet<Class> *classSet = [NSSet setWithArray:@[cls,]];
                    value = func(keyedUnarchiverClass, archiverSel, classSet, data, &error);
                    if (error) {
                        NSLog(@"%s, error = %@", __func__, error);
                    }
                }else {
                    id(*func)(id,SEL,NSData *) = (void *)archiverImp;
                    value = func(keyedUnarchiverClass, archiverSel, data);
                }
            }
        }
    }
    return value;
}

@end
