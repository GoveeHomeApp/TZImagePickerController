//
//  TZAssetModel.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZAssetModel.h"
#import "TZImageManager.h"

@implementation TZAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(TZAssetModelMediaType)type{
    TZAssetModel *model = [[TZAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(TZAssetModelMediaType)type timeLength:(NSString *)timeLength {
    TZAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}
- (NSInteger)getVideoTime {
    NSArray *times = [self.timeLength componentsSeparatedByString:@":"];
    NSInteger videoTime = 0;
    if (times.count > 0) {
        if (times.count < 3) {
            for (NSInteger i=times.count-1; i>=0; i--) {
                NSInteger timeValue = [times[i] integerValue];
                videoTime += timeValue * pow(60, times.count-i-1);
            }
        } else {
            for (NSInteger i=times.count-1; i>=0; i--) {
                if (i > 0) {
                    NSInteger timeValue = [times[i] integerValue];
                    videoTime += timeValue * pow(60, times.count-i-1);
                } else {
                    NSInteger timeValue = [times[i] integerValue];
                    if (timeValue > 0) {
                        videoTime = videoTime * timeValue;
                    }
                }
            }
        }
    }
    return videoTime;
}
@end



@implementation TZAlbumModel

- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets {
    _result = result;
    if (needFetchAssets) {
        [[TZImageManager manager] getAssetsFromFetchResult:result completion:^(NSArray<TZAssetModel *> *models) {
            self->_models = models;
            if (self->_selectedModels) {
                [self checkSelectedModels];
            }
        }];
    }
}

- (void)refreshFetchResult {
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:self.collection options:self.options];
    self.count = fetchResult.count;
    [self setResult:fetchResult];
}

- (void)setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (_models) {
        [self checkSelectedModels];
    }
}

- (void)checkSelectedModels {
    self.selectedCount = 0;
    NSMutableSet *selectedAssets = [NSMutableSet setWithCapacity:_selectedModels.count];
    for (TZAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (TZAssetModel *model in _models) {
        if ([selectedAssets containsObject:model.asset]) {
            self.selectedCount ++;
        }
    }
}

- (NSString *)name {
    if (_name) {
        return _name;
    }
    return @"";
}

@end
