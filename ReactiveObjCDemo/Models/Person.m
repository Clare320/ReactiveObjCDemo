//
//  Person.m
//  ReactiveObjCDemo
//
//  Created by lingjie on 2020/11/19.
//

#import "Person.h"

@implementation Person

- (instancetype)setNameWithFormat:(NSString *)format, ... {

    NSCParameterAssert(format != nil);

    va_list args;
    va_start(args, format);

    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    self.name = str;
    return self;
}

@end
