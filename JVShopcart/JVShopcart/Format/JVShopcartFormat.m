//
//  JVShopcartFormat.m
//  JVShopcart
//
//  Created by AVGD-Jarvi on 17/3/23.
//  Copyright © 2017年 AVGD-Jarvi. All rights reserved.
//

#import "JVShopcartFormat.h"
#import "JVShopcartBrandModel.h"
#import "MJExtension.h"
#import <UIKit/UIKit.h>

@interface JVShopcartFormat ()

@property (nonatomic, strong) NSMutableArray *shopcartListArray;    /**< 购物车数据源 */

@end

@implementation JVShopcartFormat

- (void)requestShopcartProductList {
    //这里只是简单模拟一下请求数据
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"shopcart" ofType:@"plist"];
    NSMutableArray *dataArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
    self.shopcartListArray = [JVShopcartBrandModel mj_objectArrayWithKeyValuesArray:dataArray];
    
    if ([self.delegate respondsToSelector:@selector(shopcartFormatRequestProductListDidSuccessWithArray:)]) {
        [self.delegate shopcartFormatRequestProductListDidSuccessWithArray:self.shopcartListArray];
    }
}

- (void)selectProductAtIndexPath:(NSIndexPath *)indexPath isSelected:(BOOL)isSelected {
    JVShopcartBrandModel *brandModel = self.shopcartListArray[indexPath.section];
    JVShopcartProductModel *productModel = brandModel.products[indexPath.row];
    productModel.isSelected = isSelected;
    
    BOOL isBrandSelected = YES;
    
    for (JVShopcartProductModel *aProductModel in brandModel.products) {
        if (aProductModel.isSelected == NO) {
            isBrandSelected = NO;
        }
    }
    
    brandModel.isSelected = isBrandSelected;
    
    if ([self.delegate respondsToSelector:@selector(shopcartFormatAccountForTotalPrice:totalCount:isAllSelected:)]) {
        [self.delegate shopcartFormatAccountForTotalPrice:[self accountTotalPrice] totalCount:[self accountTotalCount] isAllSelected:[self isAllSelected]];
    }
}

- (void)selectBrandAtSection:(NSInteger)section isSelected:(BOOL)isSelected {
    JVShopcartBrandModel *brandModel = self.shopcartListArray[section];
    brandModel.isSelected = isSelected;
    
    for (JVShopcartProductModel *aProductModel in brandModel.products) {
        aProductModel.isSelected = brandModel.isSelected;
    }
    
    if ([self.delegate respondsToSelector:@selector(shopcartFormatAccountForTotalPrice:totalCount:isAllSelected:)]) {
        [self.delegate shopcartFormatAccountForTotalPrice:[self accountTotalPrice] totalCount:[self accountTotalCount] isAllSelected:[self isAllSelected]];
    }
}

- (void)changeCountAtIndexPath:(NSIndexPath *)indexPath count:(NSInteger)count {
    JVShopcartBrandModel *brandModel = self.shopcartListArray[indexPath.section];
    JVShopcartProductModel *productModel = brandModel.products[indexPath.row];
    if (count == 0) {
        count = 1;
    } else if (count > productModel.productStocks) {
        count = productModel.productStocks;
    }
    
    //根据请求结果决定是否改变数据
    productModel.productQty = count;
    
    if ([self.delegate respondsToSelector:@selector(shopcartFormatAccountForTotalPrice:totalCount:isAllSelected:)]) {
        [self.delegate shopcartFormatAccountForTotalPrice:[self accountTotalPrice] totalCount:[self accountTotalCount] isAllSelected:[self isAllSelected]];
    }
}

- (void)deleteProductAtIndexPath:(NSIndexPath *)indexPath {
    JVShopcartBrandModel *brandModel = self.shopcartListArray[indexPath.section];
    JVShopcartProductModel *productModel = brandModel.products[indexPath.row];
    
    //根据请求结果决定是否删除
    [brandModel.products removeObject:productModel];
    if (brandModel.products.count == 0) {
        [self.shopcartListArray removeObject:brandModel];
    }
    
    if ([self.delegate respondsToSelector:@selector(shopcartFormatAccountForTotalPrice:totalCount:isAllSelected:)]) {
        [self.delegate shopcartFormatAccountForTotalPrice:[self accountTotalPrice] totalCount:[self accountTotalCount] isAllSelected:[self isAllSelected]];
    }
    
    if (self.shopcartListArray.count == 0) {
        if ([self.delegate respondsToSelector:@selector(shopcartFormatHasDeleteAllProducts)]) {
            [self.delegate shopcartFormatHasDeleteAllProducts];
        }
    }
}

- (void)starProductAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)selectAllProductWithStatus:(BOOL)isSelected {
    for (JVShopcartBrandModel *brandModel in self.shopcartListArray) {
        brandModel.isSelected = isSelected;
        for (JVShopcartProductModel *productModel in brandModel.products) {
            productModel.isSelected = isSelected;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(shopcartFormatAccountForTotalPrice:totalCount:isAllSelected:)]) {
        [self.delegate shopcartFormatAccountForTotalPrice:[self accountTotalPrice] totalCount:[self accountTotalCount] isAllSelected:[self isAllSelected]];
    }
}

- (void)settleSelectedProducts {
    NSMutableArray *selectedProducts = [self.shopcartListArray mutableCopy];
    for (JVShopcartBrandModel *brandModel in self.shopcartListArray) {
        for (JVShopcartProductModel *productModel in brandModel.products) {
            if (productModel.isSelected == NO) {
                [selectedProducts addObject:productModel];
            }
        }
    }
}

- (float)accountTotalPrice {
    float totalPrice = 0.f;
    for (JVShopcartBrandModel *brandModel in self.shopcartListArray) {
        for (JVShopcartProductModel *productModel in brandModel.products) {
            if (productModel.isSelected) {
                totalPrice += productModel.productPrice * productModel.productQty;
            }
        }
    }
    
    return totalPrice;
}

- (NSInteger)accountTotalCount {
    NSInteger totalCount = 0;
    
    for (JVShopcartBrandModel *brandModel in self.shopcartListArray) {
        for (JVShopcartProductModel *productModel in brandModel.products) {
            if (productModel.isSelected) {
                totalCount += productModel.productQty;
            }
        }
    }
    
    return totalCount;
}

- (BOOL)isAllSelected {
    if (self.shopcartListArray.count == 0) return NO;
    
    BOOL isAllSelected = YES;
    
    for (JVShopcartBrandModel *brandModel in self.shopcartListArray) {
        if (brandModel.isSelected == NO) {
            isAllSelected = NO;
        }
    }
    
    return isAllSelected;
}

@end