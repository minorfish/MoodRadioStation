//
//  MRSFetchResultController.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/6.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRSFetchResultController;
@class MRSFetchResultSectionInfo;

@protocol MRSFetchResultControllerProtocol <NSObject>

- (void)controllerDidChangeContent:(MRSFetchResultController *)controller;

@end

@interface MRSFetchResultController : NSObject

@property (nonatomic, weak) id<MRSFetchResultControllerProtocol> delegate;

- (NSIndexPath *)indexPathForObject:(id)object;
- (NSUInteger)numberOfObject;
- (id)objectAtIndexPath:(NSIndexPath *)indexpath;

@end

@interface MRSFetchResultController (collection)

@property (nonatomic, readonly) NSArray *sections;

- (void)insertEmptySectionAtIndex:(NSUInteger)index;

- (void)addEmptySection;

- (void)addSectionsWithObjects:(NSArray *)objects;

- (void)removeSectionAtIndex:(NSUInteger)index;

- (void)removeAllSections;

#pragma mark - mannipulate object

- (void)addObject:(id)anObject inSectionAtIndex:(NSUInteger)sectionIndex;

- (void)addObjects:(NSArray *)objects AtSectionIndex:(NSInteger)sectionIndex;

- (void)addObjectsInLastSection:(NSArray *)objects;

- (void)insertObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath;

- (void)replaceObjectAtIndex:(NSIndexPath *)indexPath withObject:(id)anObject;

- (void)insertSection:(MRSFetchResultSectionInfo *)sectionInfo atIndex:(NSUInteger)index;

- (void)addSection:(MRSFetchResultSectionInfo *)sectionInfo;

- (void)removeSection:(MRSFetchResultSectionInfo *)sectionInfo;


@end

