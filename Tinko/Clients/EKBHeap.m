//
//  EKBHeap.m
//  EKAlgorithmsApp
//
//  Created by Yifei Zhou on 3/30/14.
//  Copyright (c) 2014 Evgeny Karkan. All rights reserved.
//

#import "EKBHeap.h"
#import "Meet.h"

@interface EKBHeap ()

@end


@implementation EKBHeap

int leftLeafIndex(int rootIndex){
    int heapIndex = rootIndex+1;
    return heapIndex*2-1;
}

int rightLeafIndex(int rootIndex){
    int heapIndex = rootIndex+1;
    return heapIndex*2+1-1;
}

int heapLastIndex (NSMutableArray* A){
    return (int)A.count-1;
}

void maxHeapify(NSMutableArray<Meet *>* A, int indexRoot, NSMutableArray* B){
    if(leftLeafIndex(indexRoot)>heapLastIndex(A)){
        return;
    }
   
    double rootValue = [A[indexRoot].startTime timeIntervalSince1970];
    int largestIndex = indexRoot;
    double largestValue = rootValue;
    
    double leftLeafValue = [A[leftLeafIndex(indexRoot)].startTime timeIntervalSince1970];
    if(leftLeafValue>rootValue) {
        largestIndex = leftLeafIndex(indexRoot);
        largestValue = leftLeafValue;
    }
    if(rightLeafIndex(indexRoot)<=heapLastIndex(A)){
        double rightLeafValue = [A[rightLeafIndex(indexRoot)].startTime timeIntervalSince1970];
        if(rightLeafValue>largestValue) {
            largestIndex = rightLeafIndex(indexRoot);
            largestValue = rightLeafValue;
        }
    }
    
    if(largestIndex != indexRoot){
        [A exchangeObjectAtIndex:indexRoot withObjectAtIndex:largestIndex];
        [B exchangeObjectAtIndex:indexRoot withObjectAtIndex:largestIndex];
        maxHeapify(A, largestIndex, B);
    }
}

void buildMaxHeap(NSMutableArray<Meet *>* A, NSMutableArray* B){
    if(A.count<2) return;
    int lastParentIndex = (int)A.count/2;
    for (int parentIndex = lastParentIndex; parentIndex >= 0; parentIndex--) {
        maxHeapify(A, parentIndex, B);
    }
}

NSDictionary* heapSort(NSMutableArray<Meet *>* A, NSMutableArray* B){
    if(A.count<2) return @{@"meetsArray":A, @"meetsIdArray":B};
    buildMaxHeap(A, B);
    NSMutableArray* sortedA = [NSMutableArray new];
    NSMutableArray* sortedB = [NSMutableArray new];
    for (int i = (int)A.count-1; i>0; i--) {
        [sortedA insertObject:A[0] atIndex:0];
        [sortedB insertObject:B[0] atIndex:0];
        [A exchangeObjectAtIndex:0 withObjectAtIndex:A.count-1];
        [B exchangeObjectAtIndex:0 withObjectAtIndex:B.count-1];
        [A removeLastObject];
        [B removeLastObject];
        maxHeapify(A, 0, B);
    }
    [sortedA insertObject:A[0] atIndex:0];
    [sortedB insertObject:B[0] atIndex:0];
    return @{@"meetsArray":sortedA, @"meetsIdArray":sortedB};
}
@end