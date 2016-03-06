//
//  MRSFetchResultController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/6.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSFetchResultController.h"
#import "MRSFetchResultSectionInfo.h"
#import <UIKit/UIKit.h>

@interface MRSFetchResultController()

@property (nonatomic, readwrite) NSMutableArray *sections;
@property (nonatomic, assign) NSInteger blockLever;

@end

@implementation MRSFetchResultController {
    NSUInteger _numberOfObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sections = [NSMutableArray array];
        
    }
    return self;
}

#pragma mark - public interface

- (NSIndexPath *)indexPathForObject:(id)object
{
    __block NSIndexPath *indexPath;
    [self.sections enumerateObjectsUsingBlock:^(MRSFetchResultSectionInfo *  _Nonnull sectionInfo, NSUInteger sectionIndex, BOOL * _Nonnull outerStop) {
        [sectionInfo.objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger objectIndex, BOOL * _Nonnull stop) {
            if ([obj isEqual:object]) {
                indexPath = [NSIndexPath indexPathForRow:objectIndex inSection:sectionIndex];
                *stop = *outerStop = YES;
            }
        }];
    }];
    return indexPath;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexpath
{
    return [self.sections[indexpath.section] objects][indexpath.row];
}

- (NSUInteger)numberOfObject
{
    return _numberOfObject;
}

#pragma mark - private

- (void)setBlockLever:(NSInteger)blockLever
{
    _blockLever = blockLever;
    if (!_blockLever) {
        [self notifyDelegate];
    }
}

- (void)performChanges:(void(^)(void))changes
{
    self.blockLever++;
    if (changes) {
        changes();
    }
    self.blockLever--;
}

- (void)notifyDelegate
{
    if ([self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
        if ([NSThread mainThread]) {
            [self.delegate controllerDidChangeContent:self];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate controllerDidChangeContent:self];
            });
        }
    }
}

- (void)notifyDelegateIfNotInBlock
{
    if (!self.blockLever) {
        [self notifyDelegate];
    }
}

#pragma mark - mannipulate sections
- (void)insertEmptySectionAtIndex:(NSUInteger)index
{
    MRSFetchResultSectionInfo *emptySection = [[MRSFetchResultSectionInfo alloc] init];
    [self.sections insertObject:emptySection atIndex:index];
    [self notifyDelegateIfNotInBlock];
}

- (void)addEmptySection
{
    [self insertEmptySectionAtIndex:self.sections.count];
    [self notifyDelegateIfNotInBlock];
}

- (void)addSectionsWithObjects:(NSArray *)objects
{
    [self performChanges:^{
        [self addEmptySection];
        [self addObjects:objects AtSectionIndex:self.sections.count - 1];
    }];
}

- (void)removeSectionAtIndex:(NSUInteger)index
{
    MRSFetchResultSectionInfo *section = self.sections[index];
    [self.sections removeObjectAtIndex:index];
    _numberOfObject -= [section.objects count];
    [self notifyDelegateIfNotInBlock];
}

- (void)removeAllSections
{
    [self.sections removeAllObjects];
    _numberOfObject = 0;
    [self notifyDelegateIfNotInBlock];
}

#pragma mark - mannipulate object

- (void)addObject:(id)anObject inSectionAtIndex:(NSUInteger)sectionIndex
{
    [(NSMutableArray *)[self.sections[sectionIndex] objects] arrayByAddingObject:anObject];
    _numberOfObject++;
    [self notifyDelegateIfNotInBlock];
}

- (void)addObjects:(NSArray *)objects AtSectionIndex:(NSInteger)sectionIndex
{
    [(NSMutableArray*)[self.sections[sectionIndex] objects] addObjectsFromArray:objects];
    _numberOfObject += objects.count;
    [self notifyDelegateIfNotInBlock];
}

- (void)addObjectsInLastSection:(NSArray *)objects
{
    [self performChanges:^{
        if (![self.sections count]) {
            [self addEmptySection];
        }
        [self addObjects:objects AtSectionIndex:self.sections.count - 1];
    }];
}

- (void)insertObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    [(NSMutableArray *)[self.sections[indexPath.section] objects]insertObject:object atIndex:indexPath.row];
    _numberOfObject++;
    [self notifyDelegateIfNotInBlock];
}

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath
{
    [(NSMutableArray *)[self.sections[indexPath.section] objects] removeObjectAtIndex:indexPath.row];
    _numberOfObject--;
    [self notifyDelegateIfNotInBlock];
}

- (void)replaceObjectAtIndex:(NSIndexPath *)indexPath withObject:(id)anObject
{
    [(NSMutableArray *)[self.sections[indexPath.section] objects]replaceObjectAtIndex:indexPath.row withObject:anObject];
    [self notifyDelegateIfNotInBlock];
}

- (void)insertSection:(MRSFetchResultSectionInfo *)sectionInfo atIndex:(NSUInteger)index
{
    if ([self.sections containsObject:sectionInfo])
        return;
    
    [self.sections insertObject:sectionInfo atIndex:index];
    _numberOfObject += [sectionInfo.objects count];
    [self notifyDelegateIfNotInBlock];
}

- (void)addSection:(MRSFetchResultSectionInfo *)sectionInfo
{
    [self insertSection:sectionInfo atIndex:self.sections.count];
}

- (void)removeSection:(MRSFetchResultSectionInfo *)sectionInfo
{
    if (![self.sections containsObject:sectionInfo]) {
        return;
    }
    [self.sections removeObject:sectionInfo];
    _numberOfObject -= [sectionInfo.objects count];
    [self notifyDelegateIfNotInBlock];
}

@end
