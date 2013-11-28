//
//  main.m
//  Primenumbers
//
//  Created by Constantijn Smit on 22-11-13.
//  Copyright (c) 2013 Constantijn Smit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach_time.h>

double MachTimeToSecs(uint64_t time)
{
  mach_timebase_info_data_t timebase;
  mach_timebase_info(&timebase);
  return (double)time * (double)timebase.numer / (double)timebase.denom / 1e6;
}

int main(int argc, const char * argv[])
{
  
  @autoreleasepool {
    
    // calculating primenumbers dirty-style.
    int size = 1000;
    uint64_t i, j, count = 0;
    NSMutableArray *primenumbers = [[NSMutableArray alloc] initWithCapacity:size];
    
    uint64_t startTime = mach_absolute_time(); // timer to check performance.
    
    for(i = 2; i < size; i++) { // start at 2, 0 and 1 are never primes.
      for(j = 2; j <= i; j++) { // start at 2, since every number can be divided by 1.
        if(i % j == 0 && i != j) { // check for every number up to i if it can divide i. Except when i == j.
          count++;
        }
      }
      
      if(count == 0) { // if count == 0, i could not be divided by any number except 1 and itself. Thus a prime.
        NSNumber *prime = [NSNumber numberWithUnsignedLongLong:i]; // add primes to an array.
        [primenumbers addObject:prime];
      }
      count = 0;
    }
    
    uint64_t endTime = mach_absolute_time();
    double time = MachTimeToSecs(endTime - startTime);
    NSLog(@"Time in milliseconds: %f", time);
    
    //NSLog(@"Primenumbers up to %i are %@", size, primenumbers);
    NSLog(@"--------------------");
    
    // calculating primenumbers with Sieve of Eratosthenes.
    NSMutableArray *primesIndex = [[NSMutableArray alloc] initWithCapacity:size];
    
    startTime = mach_absolute_time();
    // fill primesIndex with TRUE's (meaning every index could be a prime)
    for (i = 0; i < size; i++) {
      [primesIndex insertObject:[NSNumber numberWithBool:TRUE] atIndex:i];
    }
    
    primesIndex[0] = [NSNumber numberWithBool:FALSE]; // 0 is never a prime
    primesIndex[1] = [NSNumber numberWithBool:FALSE]; // 1 is never a prime
    
    for(i = 2; i*i < size; i++) { // note: only need to check up to squareroot of max.
      if(primesIndex[i] == [NSNumber numberWithBool:TRUE]) { // if primeIndex has value TRUE, it's a prime
        for (j = i*i; j < size; j += i) { // note: start at square of current prime. Cross out (== FALSE) multiples of prime.
          primesIndex[j] = [NSNumber numberWithBool:FALSE];
        }
      }
    }
    
    endTime = mach_absolute_time();
    time = endTime -startTime;
    NSLog(@"SoE. time in milliseconds: %f", MachTimeToSecs(time));
    
    NSLog(@"--------------------");
    
    // calculating primenumbers with Sieve of Eratosthenes using C-array instead of Objective-C array.
    char index[size + 1];
    
    startTime = mach_absolute_time();
    
    // fill index with 1's (meaning every index could be a prime)
    for (i = 0; i < size; i++) {
      index[i] = 1;
    }
    
    index[0] = 0; // 0 is never a prime
    index[1] = 0; // 1 is never a prime
    
    for(i = 2; i*i < size; i++) { // note: only need to check up to squareroot of max.
      if(index[i] == 1) { // if index has value 1, it's a prime
        for (j = i*i; j < size; j += i) { // note: start at square of current prime. Cross out (== 0) multiples of prime.
          index[j] = 0;
        }
      }
    }
    
    endTime = mach_absolute_time();
    time = endTime -startTime;
    NSLog(@"SoE; C array. time in milliseconds: %f", MachTimeToSecs(time));
    
  }
  return 0;
}

