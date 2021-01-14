//
//  Person.h
//  ReactiveObjCDemo
//
//  Created by lingjie on 2020/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSInteger age;

@property (nonatomic, assign) CGSize houseSize;

- (instancetype)setNameWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

@end

NS_ASSUME_NONNULL_END
