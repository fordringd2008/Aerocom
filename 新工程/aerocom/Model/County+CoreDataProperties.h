//
//  County+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/14.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "County.h"

NS_ASSUME_NONNULL_BEGIN

@interface County (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *countyID;
@property (nullable, nonatomic, retain) NSString *countyName;
@property (nullable, nonatomic, retain) NSNumber *language;
@property (nullable, nonatomic, retain) NSDate *writeTime;
@property (nullable, nonatomic, retain) NSSet<State *> *states;

@end

@interface County (CoreDataGeneratedAccessors)

- (void)addStatesObject:(State *)value;
- (void)removeStatesObject:(State *)value;
- (void)addStates:(NSSet<State *> *)values;
- (void)removeStates:(NSSet<State *> *)values;

@end

NS_ASSUME_NONNULL_END
