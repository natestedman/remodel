Feature: Outputting Value Objects With Forward Declarations

  @announce
  Scenario: Generating Header Files with forwards
    Given a file named "project/values/RMPage.value" with:
      """
      # Important and gripping comment
      # that takes up two lines.
      %type name=RMSomeType library=FooLibrary
      %type name=UIViewController library=UIKit
      RMPage includes(UseForwardDeclarations) {
        BOOL doesUserLike
        NSString* identifier
        # And another important comment.
        # which also takes 2 lines.
        NSInteger likeCount
        NSUInteger numberOfRatings
        RMProxy* proxy
        NSArray<RMSomeType *>* followers
        %import library=HelloKit file=HelloProtocol
        id<HelloProtocol> helloObj
        %import library=WorldKit file=HWorldProtocol
        UIViewController<WorldProtocol> *worldVc
      }
      """
    And a file named "project/.valueObjectConfig" with:
      """
      { }
      """
    When I run `../../bin/generate project`
    Then the file "project/values/RMPage.h" should contain:
      """
      #import <Foundation/Foundation.h>

      @class RMSomeType;
      @class UIViewController;
      @class RMProxy;
      @protocol HelloProtocol;
      @protocol WorldProtocol;

      /**
       * Important and gripping comment
       * that takes up two lines.
       */
      @interface RMPage : NSObject <NSCopying>

      @property (nonatomic, readonly) BOOL doesUserLike;
      @property (nonatomic, readonly, copy) NSString *identifier;
      /**
       * And another important comment.
       * which also takes 2 lines.
       */
      @property (nonatomic, readonly) NSInteger likeCount;
      @property (nonatomic, readonly) NSUInteger numberOfRatings;
      @property (nonatomic, readonly, copy) RMProxy *proxy;
      @property (nonatomic, readonly, copy) NSArray<RMSomeType *> *followers;
      @property (nonatomic, readonly) id<HelloProtocol> helloObj;
      @property (nonatomic, readonly, copy) UIViewController<WorldProtocol> *worldVc;

      + (instancetype)new NS_UNAVAILABLE;

      - (instancetype)init NS_UNAVAILABLE;

      - (instancetype)initWithDoesUserLike:(BOOL)doesUserLike identifier:(NSString *)identifier likeCount:(NSInteger)likeCount numberOfRatings:(NSUInteger)numberOfRatings proxy:(RMProxy *)proxy followers:(NSArray<RMSomeType *> *)followers helloObj:(id<HelloProtocol>)helloObj worldVc:(UIViewController<WorldProtocol> *)worldVc NS_DESIGNATED_INITIALIZER;

      @end

      """
   And the file "project/values/RMPage.m" should contain:
      """
      #import "RMPage.h"
      #import <FooLibrary/RMSomeType.h>
      #import <UIKit/UIViewController.h>
      #import "RMProxy.h"
      #import <HelloKit/HelloProtocol.h>
      #import <WorldKit/HWorldProtocol.h>

      @implementation RMPage

      - (instancetype)initWithDoesUserLike:(BOOL)doesUserLike identifier:(NSString *)identifier likeCount:(NSInteger)likeCount numberOfRatings:(NSUInteger)numberOfRatings proxy:(RMProxy *)proxy followers:(NSArray<RMSomeType *> *)followers helloObj:(id<HelloProtocol>)helloObj worldVc:(UIViewController<WorldProtocol> *)worldVc
      {
        if ((self = [super init])) {
          _doesUserLike = doesUserLike;
          _identifier = [identifier copy];
          _likeCount = likeCount;
          _numberOfRatings = numberOfRatings;
          _proxy = [proxy copy];
          _followers = [followers copy];
          _helloObj = helloObj;
          _worldVc = [worldVc copy];
        }

        return self;
      }

      - (id)copyWithZone:(nullable NSZone *)zone
      {
        return self;
      }

      - (NSString *)description
      {
        return [NSString stringWithFormat:@"%@ - \n\t doesUserLike: %@; \n\t identifier: %@; \n\t likeCount: %lld; \n\t numberOfRatings: %llu; \n\t proxy: %@; \n\t followers: %@; \n\t helloObj: %@; \n\t worldVc: %@; \n", [super description], _doesUserLike ? @"YES" : @"NO", _identifier, (long long)_likeCount, (unsigned long long)_numberOfRatings, _proxy, _followers, _helloObj, _worldVc];
      }

      - (NSUInteger)hash
      {
        NSUInteger subhashes[] = {(NSUInteger)_doesUserLike, [_identifier hash], ABS(_likeCount), _numberOfRatings, [_proxy hash], [_followers hash], [_helloObj hash], [_worldVc hash]};
        NSUInteger result = subhashes[0];
        for (int ii = 1; ii < 8; ++ii) {
          unsigned long long base = (((unsigned long long)result) << 32 | subhashes[ii]);
          base = (~base) + (base << 18);
          base ^= (base >> 31);
          base *=  21;
          base ^= (base >> 11);
          base += (base << 6);
          base ^= (base >> 22);
          result = base;
        }
        return result;
      }

      - (BOOL)isEqual:(RMPage *)object
      {
        if (self == object) {
          return YES;
        } else if (object == nil || ![object isKindOfClass:[self class]]) {
          return NO;
        }
        return
          _doesUserLike == object->_doesUserLike &&
          _likeCount == object->_likeCount &&
          _numberOfRatings == object->_numberOfRatings &&
          (_identifier == object->_identifier ? YES : [_identifier isEqual:object->_identifier]) &&
          (_proxy == object->_proxy ? YES : [_proxy isEqual:object->_proxy]) &&
          (_followers == object->_followers ? YES : [_followers isEqual:object->_followers]) &&
          (_helloObj == object->_helloObj ? YES : [_helloObj isEqual:object->_helloObj]) &&
          (_worldVc == object->_worldVc ? YES : [_worldVc isEqual:object->_worldVc]);
      }

      @end

      """
  @announce
  Scenario: Generating Files with no equality and a custom base type
    Given a file named "project/values/RMPage.value" with:
      """
      RMPage includes(UseForwardDeclarations) {
        BOOL doesUserLike
        NSString* identifier
        NSInteger likeCount
        CGFloat countIconHeight
        CGFloat countIconWidth
        NSUInteger numberOfRatings
        Foo* foo
      }
      """
    And a file named "project/.valueObjectConfig" with:
      """
      {
        "customBaseClass": { "className": "RMProxy", "libraryName": "RMProxyLib" },
        "diagnosticIgnores": ["-Wprotocol"],
        "defaultExcludes": [
          "RMEquality"
         ]
      }
      """
    When I run `../../bin/generate project`
    Then the file "project/values/RMPage.h" should contain:
      """
      /**
       * This file is generated using the remodel generation script.
       * The name of the input file is RMPage.value
       */

      #import <RMProxyLib/RMProxy.h>
      #import <Foundation/Foundation.h>
      #import <CoreGraphics/CGBase.h>

      @class Foo;

      @interface RMPage : RMProxy <NSCopying>

      @property (nonatomic, readonly) BOOL doesUserLike;
      @property (nonatomic, readonly, copy) NSString *identifier;
      @property (nonatomic, readonly) NSInteger likeCount;
      @property (nonatomic, readonly) CGFloat countIconHeight;
      @property (nonatomic, readonly) CGFloat countIconWidth;
      @property (nonatomic, readonly) NSUInteger numberOfRatings;
      @property (nonatomic, readonly, copy) Foo *foo;

      + (instancetype)new NS_UNAVAILABLE;

      - (instancetype)init NS_UNAVAILABLE;

      - (instancetype)initWithDoesUserLike:(BOOL)doesUserLike identifier:(NSString *)identifier likeCount:(NSInteger)likeCount countIconHeight:(CGFloat)countIconHeight countIconWidth:(CGFloat)countIconWidth numberOfRatings:(NSUInteger)numberOfRatings foo:(Foo *)foo NS_DESIGNATED_INITIALIZER;

      @end

      """
   And the file "project/values/RMPage.m" should contain:
      """
      #import "RMPage.h"
      #import "Foo.h"

      #pragma clang diagnostic push
      #pragma GCC diagnostic ignored "-Wprotocol"

      @implementation RMPage

      - (instancetype)initWithDoesUserLike:(BOOL)doesUserLike identifier:(NSString *)identifier likeCount:(NSInteger)likeCount countIconHeight:(CGFloat)countIconHeight countIconWidth:(CGFloat)countIconWidth numberOfRatings:(NSUInteger)numberOfRatings foo:(Foo *)foo
      {
        if ((self = [super init])) {
          _doesUserLike = doesUserLike;
          _identifier = [identifier copy];
          _likeCount = likeCount;
          _countIconHeight = countIconHeight;
          _countIconWidth = countIconWidth;
          _numberOfRatings = numberOfRatings;
          _foo = [foo copy];
        }

        return self;
      }

      - (id)copyWithZone:(nullable NSZone *)zone
      {
        return self;
      }

      - (NSString *)description
      {
        return [NSString stringWithFormat:@"%@ - \n\t doesUserLike: %@; \n\t identifier: %@; \n\t likeCount: %lld; \n\t countIconHeight: %f; \n\t countIconWidth: %f; \n\t numberOfRatings: %llu; \n\t foo: %@; \n", [super description], _doesUserLike ? @"YES" : @"NO", _identifier, (long long)_likeCount, _countIconHeight, _countIconWidth, (unsigned long long)_numberOfRatings, _foo];
      }

      @end
      #pragma clang diagnostic pop

      """
  @announce
  Scenario: Generating Files with SkipAttributePrivateImports results in no additional imports
    Given a file named "project/values/RMPage.value" with:
      """
      RMPage includes(UseForwardDeclarations, SkipAttributePrivateImports) {
        UIViewController<WorldProtocol> *worldVc
        RMProxy* proxy
        HelloClass *helloObj
        NSArray<RMSomeType *>* followers
      }
      """
    And a file named "project/.valueObjectConfig" with:
      """
      { }
      """
    When I run `../../bin/generate project`
    Then the file "project/values/RMPage.m" should contain:
      """
      #import "RMPage.h"

      @implementation RMPage

      """
