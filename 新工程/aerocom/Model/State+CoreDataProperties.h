//
//  State+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/14.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "State.h"

NS_ASSUME_NONNULL_BEGIN

@interface State (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *language;
@property (nullable, nonatomic, retain) NSNumber *stateID;
@property (nullable, nonatomic, retain) NSString *stateName;
@property (nullable, nonatomic, retain) NSDate *writeTime;
@property (nullable, nonatomic, retain) County *county;

@end

NS_ASSUME_NONNULL_END
