//
// Created by Shire on 10/27/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBModelObject.h"


@interface TBFile : TBModelObject

@property (nonatomic, copy) NSString * fileName;
@property (nonatomic, copy) NSString * fileKey;
@property (nonatomic, copy) NSString * fileType;
@property (nonatomic, copy) NSString * fileCategory;
@property (nonatomic) NSNumber *fileSize;
@property (nonatomic) NSNumber *imageWidth;
@property (nonatomic) NSNumber *imageHeight;
@property (nonatomic, copy) NSURL * thumbnailURL;
@property (nonatomic, copy) NSURL * downloadURL;
@property (nonatomic, copy) NSString * messageID;
@property (nonatomic, copy) NSString * creatorID;
@property (nonatomic, copy) NSString * teamID;
@property (nonatomic, copy) NSString * roomID;
@property (nonatomic) BOOL isSpeech;
@property (nonatomic) NSNumber *duration;

@end